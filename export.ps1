# Requires -Version 5.1

<#
.SYNOPSIS
    Tc3 Message Extractor - Final Version (Exports JSON without empty translation fields)
.DESCRIPTION
    Scans TwinCAT source files for M_Info, M_Warning, M_Error, and M_Critical calls.
    - Validates and corrects message IDs based on a hash of the message text.
    - Replaces IDs of 0 with the correct hash.
    - Generates new IDs for messages that don't have one.
    - Updates source files in-place.
    - Merges findings into a central messages.json file.
    - Exports to EventClass.xml for TwinCAT Event Manager.
#>

param(
    [string[]]$Languages = @("en", "de", "es") 
)

 $script:Config = @{
    IdWidth = 8
    # CHANGE 1: Pattern now matches message first, ID second, and excludes Verbose.
    MessagePattern = '(\w+\.)?M_(Info|Warning|Error|Critical)\s*\(\s*''([^'']+)''\s*,\s*([0-9]*)\s*\)(.*)'
    FileFilter = "*.TcPOU"
    PlaceholderMap = @{ '%s' = '{0}' }
    OutputJson = "messages.json"
    OutputXml = "EventClass.xml"
}

# --- Minimal Logger ---
function Write-Log {
    param([string]$Message, [string]$Level = "Info")
    if ($Level -ne "Debug") {
        $color = switch ($Level) { "Warning" {"Yellow"} "Error" {"Red"} Default {"Green"} }
        Write-Host "[$Level] $Message" -ForegroundColor $color
    }
}

function Format-MessageId { param([uint32]$Id); return "{0:D$($script:Config.IdWidth)}" -f $Id }

function Get-UDINTHash {
    param([string]$s)
    [int64]$p = 37; [int64]$m = 1000000009; [int64]$hash = 0; [int64]$pPow = 1
    foreach ($ch in $s.ToCharArray()) {
        [int64]$cVal = [int][char]$ch 
        $hash = ($hash + ($cVal * $pPow) % $m) % $m
        $pPow = ($pPow * $p) % $m
    }
    return [uint32]$hash
}

function Convert-Placeholders {
    param([string]$text)
    $pat = $script:Config.PlaceholderMap.Keys -join '|'
    $idx = 0
    return [regex]::Replace($text, "($pat)", { 
        param($m); $r = "{$idx}"; Set-Variable -Name 'idx' -Value ($idx + 1) -Scope 1; $r 
    })
}

# --- Main Execution ---

try {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if (-not $gitRoot) { throw "Not a git repo" }
    $rootFolder = $gitRoot.Trim()
} catch { $rootFolder = $PSScriptRoot }

 $outputFile = Join-Path $rootFolder $script:Config.OutputJson
 $outputXmlFile = Join-Path $rootFolder $script:Config.OutputXml

# 1. Scan Files
 $files = Get-ChildItem -Path $rootFolder -Recurse -Include $script:Config.FileFilter -ErrorAction SilentlyContinue
if (-not $files) { return }

 $scannedMessages = @{}
 $idTracker = @{}
 $modifiedFiles = 0
 $totalFiles = $files.Count
 $conflictLog = @()

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        if ([string]::IsNullOrWhiteSpace($content)) { continue }
        
        # Extract POU name from XML
        $pouName = ""
        if ($content -match '<POU Name="([^"]+)"') {
            $pouName = $matches[1]
        } else {
            # Fallback to filename without extension if POU name not found
            $pouName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        }
        
        $modified = $false
        $content = [regex]::Replace($content, $script:Config.MessagePattern, {
            param($m)
            # CHANGE 2: Swapped variables to match new capture group order (message, then ID)
            $pre, $type, $txt, $idStr, $suf = $m.Groups[1].Value, $m.Groups[2].Value, $m.Groups[3].Value.Trim(), $m.Groups[4].Value.Trim(), $m.Groups[5].Value
            if ([string]::IsNullOrWhiteSpace($txt)) { return $m.Value }

            [uint32]$id = 0; $hasId = [uint32]::TryParse($idStr, [ref]$id); $hashId = [uint32](Get-UDINTHash $txt)
            
            # FIX 1: Only generate a new ID if the ID is missing/unparsable, not if it's 0
            if (-not $hasId) { 
                $id = $hashId; $modified = $true 
            }
            # FIX 2: Always validate the hash, even for ID 0
            elseif ($id -ne $hashId) {
                $oldId = $id
                # FIX 3: Check if the hashId key exists in the tracker before accessing it
                if ($idTracker.ContainsKey($hashId) -and $idTracker[$hashId].key -ne $txt) { 
                    $id = [uint32](Get-UDINTHash "$($txt)_fix") 
                    $conflictType = "Collision Resolved"
                } 
                else { 
                    $id = $hashId 
                    $conflictType = "Hash Corrected"
                }
                $modified = $true
                $conflictLog += "[ID $oldId -> $id] $conflictType for '$txt'"
            }

            if (-not $scannedMessages.ContainsKey($id)) { 
                $scannedMessages[$id] = @{ 
                    id = $id; 
                    key = $txt; 
                    source = @($pouName) 
                } 
            } else {
                # Add POU name to source array if not already present
                if ($pouName -notin $scannedMessages[$id].source) {
                    $scannedMessages[$id].source += $pouName
                }
            }
            
            $idTracker[$id] = @{ id = $id; key = $txt }
            # CHANGE 3: Output in the new format: message first, ID second
            return "$pre`M_$type('$txt', $id)$suf"
        })

        if ($modified) { 
            Set-Content $file.FullName -Value $content -NoNewline -Encoding UTF8
            $modifiedFiles++
        }
    } catch { Write-Log "Error reading $($file.Name): $_" -Level Error }
}

# --- Report on initial scan ---
Write-Log "Parsed $totalFiles files, found $($scannedMessages.Count) total messages." -Level Info
if ($modifiedFiles -gt 0) { Write-Log "Fixed IDs in $modifiedFiles source files." -Level Warning }
if ($conflictLog.Count -gt 0) { 
    Write-Log "Detected and resolved $($conflictLog.Count) message ID conflicts/corrections." -Level Warning
    Write-Log "--- Conflict Details ---" -Level Info
    foreach ($logEntry in $conflictLog) {
        Write-Log $logEntry -Level Info
    }
    Write-Log "--------------------------" -Level Info
}

# 2. Merge JSON
 $finalMessages = [System.Collections.Specialized.OrderedDictionary]::new()
 $keyToIdMap = @{}
 $duplicateKeyLog = @{}

if (Test-Path $outputFile) {
    try {
        $rawJson = Get-Content -Path $outputFile -Raw -Encoding UTF8 | ConvertFrom-Json
        $rawMessages = $rawJson.Events
        if (-not $rawMessages) { $rawMessages = $rawJson.Messages }
        if (-not $rawMessages) { $rawMessages = $rawJson }

        foreach ($msg in $rawMessages) {
            $currentId = [uint32]::Parse($msg.id)
            $messageKey = $msg.key.Trim()
            $correctHash = [uint32](Get-UDINTHash $messageKey)

            if ($keyToIdMap.ContainsKey($messageKey)) {
                $existingId = $keyToIdMap[$messageKey]
                $currentIsCorrect = ($currentId -eq $correctHash)
                $existingIsCorrect = ($existingId -eq $correctHash)
                
                $action = ""
                $removedId = ""
                
                if ($existingIsCorrect -and -not $currentIsCorrect) {
                    $action = "SKIP"; $removedId = $currentId
                }
                elseif ($currentIsCorrect -and -not $existingIsCorrect) {
                    $finalMessages.Remove($existingId)
                    $keyToIdMap[$messageKey] = $currentId
                    $action = "REPLACE"; $removedId = $existingId
                }
                else {
                    $action = "SKIP"; $removedId = $currentId
                }

                $duplicateKeyLog += "[Duplicate Key] Removed ID $removedId because '$messageKey' is defined by canonical ID $($keyToIdMap[$messageKey]). (Hash: $correctHash)"
                
                if ($action -eq "SKIP") { continue }
            }
            
            $keyToIdMap[$messageKey] = $currentId
            
            $dict = [System.Collections.Specialized.OrderedDictionary]::new()
            foreach ($prop in $msg.PSObject.Properties) {
                if ($prop.Name -eq "en") { continue }
                $dict[$prop.Name] = $prop.Value
            }
            $finalMessages[$currentId] = $dict
        }
    } catch { Write-Log "Error processing existing JSON. Starting merge fresh." -Level Error }
}

# --- Report on JSON Cleanup ---
if ($duplicateKeyLog.Count -gt 0) { 
    Write-Log "Cleaned up $($duplicateKeyLog.Count) event entries with duplicate 'key' text in messages.json." -Level Warning
    Write-Log "--- JSON Cleanup Details ---" -Level Info
    foreach ($logEntry in $duplicateKeyLog) {
        Write-Log $logEntry -Level Info
    }
    Write-Log "--------------------------" -Level Info
}

# 3. Merge Scanned Data
 $newCount = 0
 $newMessagesList = @()

foreach ($scan in $scannedMessages.Values | Sort-Object id) {
    $id = $scan.id
    # FIX 4: Use .Contains() for OrderedDictionary, not .ContainsKey()
    if (-not $finalMessages.Contains($id)) {
        $newCount++
        $newMessagesList += @{Id = (Format-MessageId $id); Text = $scan.key}
        $finalMessages[$id] = [Ordered]@{ 
            id = (Format-MessageId $id); 
            key = $scan.key;
            source = $scan.source
        }
    }
    $finalMessages[$id]["key"] = $scan.key
    
    # Merge source arrays
    if ($finalMessages[$id].Contains("source")) {
        $existingSources = $finalMessages[$id]["source"]
        if ($existingSources -isnot [array]) {
            $existingSources = @($existingSources)
        }
        
        $newSources = $scan.source
        if ($newSources -isnot [array]) {
            $newSources = @($newSources)
        }
        
        # Combine and deduplicate sources
        $allSources = $existingSources + $newSources | Sort-Object -Unique
        $finalMessages[$id]["source"] = $allSources
    } else {
        $finalMessages[$id]["source"] = $scan.source
    }
    
    # Ensure all translation keys exist, but DON'T initialize them to "" here.
    foreach ($lang in $Languages) {
        if ($lang -ne "en" -and -not $finalMessages[$id].Contains($lang)) { 
            # If the entry is brand new, we won't add the language key yet, it will be added when translated.
            # If it's existing but the language was missed, ensure it's at least present for the next step.
            # For simplicity and to achieve the requested output, we rely on the final cleanup step.
        }
    }
}

# --- Report on new messages ---
if ($newCount -gt 0) { 
    $totalMessagesAfter = $finalMessages.Count
    Write-Log "Added $newCount new messages (Total unique: $totalMessagesAfter)." -Level Warning
    
    Write-Log "--- New Messages Details ---" -Level Info
    foreach ($msg in $newMessagesList) {
        Write-Log "New: [$($msg.Id)] $($msg.Text)" -Level Info
    }
    Write-Log "--------------------------" -Level Info
}

# 4. Export (JSON and XML)
try {
    # Cleanup pass: Remove language fields if they contain empty strings.
    $cleanedSortedList = @()
    foreach ($messageObject in $finalMessages.Values | Sort-Object id) {
        $cleanedObject = [System.Collections.Specialized.OrderedDictionary]::new()
        
        foreach ($prop in $messageObject.Keys) {
            $value = $messageObject[$prop]
            
            # Keep 'id', 'key', and 'source' regardless. 
            # Keep other properties (languages) ONLY if the value is NOT an empty string.
            if ($prop -eq "id" -or $prop -eq "key" -or $prop -eq "source" -or -not ([string]::IsNullOrEmpty($value))) {
                $cleanedObject[$prop] = $value
            }
        }
        $cleanedSortedList += $cleanedObject
    }
    
    # JSON Export with 'Events' array
    $outputObject = [Ordered]@{ locale = $Languages; Events = $cleanedSortedList }
    $outputObject | ConvertTo-Json -Depth 5 | Set-Content -Path $outputFile -Encoding UTF8
    
    # XML Export (remains unchanged)
    $xmlDoc = [System.Xml.XmlDocument]::new()
    $xmlDec = $xmlDoc.CreateXmlDeclaration("1.0", "utf-8", $null)
    [void]$xmlDoc.AppendChild($xmlDec) 
    $rootEl = $xmlDoc.CreateElement("EventClass")
    [void]$xmlDoc.AppendChild($rootEl)
    foreach ($msg in $scannedMessages.Values | Sort-Object id) {
        $ev = $xmlDoc.CreateElement("EventId")
        $nm = $xmlDoc.CreateElement("Name"); $nm.SetAttribute("Id", (Format-MessageId $msg.id)); $nm.InnerText = "Tc3_Event_$($msg.id)"
        $dn = $xmlDoc.CreateElement("DisplayName"); $dn.SetAttribute("TxtId", "")
        $cd = $xmlDoc.CreateCDataSection((Convert-Placeholders $msg.key))
        [void]$dn.AppendChild($cd); [void]$ev.AppendChild($nm); [void]$ev.AppendChild($dn); [void]$rootEl.AppendChild($ev)
    }
    $xmlDoc.Save($outputXmlFile)
    
    Write-Log "Done." -Level Info
} catch { Write-Log "Export Failed: $_" -Level Error }