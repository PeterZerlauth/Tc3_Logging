# Requires -Version 5.1

<#
.SYNOPSIS
    Tc3 Message Extractor - Clean JSON Version

.DESCRIPTION
    Scans TwinCAT source files for M_Info, M_Warning, M_Error, M_Critical.
    Validates IDs using message hash, updates sources, and exports clean JSON/XML structures.
#>

param(
    [string[]]$Languages = @("en", "de", "es")
)

# ============================================================
# Configuration
# ============================================================
$script:Config = @{
    IdWidth        = 8
    MessagePattern = [regex]::new('(\w+\.)?M_(Info|Warning|Error|Critical)\s*\(\s*''([^'']+)''\s*,\s*([0-9]*)\s*\)(.*)', [System.Text.RegularExpressions.RegexOptions]::Compiled)
    FileFilter     = "*.TcPOU"
    PlaceholderMap = @{ '%s' = '{0}' }
    OutputJson     = "messages.json"
    OutputXml      = "EventClass.xml"
}

# Pre-compiled regex pattern for placeholder conversions
$script:PlaceholderPattern = [regex]::new(($script:Config.PlaceholderMap.Keys -join "|"), [System.Text.RegularExpressions.RegexOptions]::Compiled)

# ============================================================
# Core Functions
# ============================================================
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )
    if ($Level -eq "Debug") { return }
    
    $color = switch ($Level) {
        "Warning" { "Yellow" }
        "Error"   { "Red" }
        default   { "Green" }
    }
    Write-Host "[$Level] $Message" -ForegroundColor $color
}

function Format-MessageId {
    param([uint32]$Id)
    return "{0:D$($script:Config.IdWidth)}" -f $Id
}

function Get-UDINTHash {
    param([string]$s)

    [int64]$p = 37
    [int64]$m = 1000000009
    [int64]$hash = 0
    [int64]$pPow = 1

    $chars = $s.ToCharArray()
    for ($i = 0; $i -lt $chars.Count; $i++) {
        [int64]$c = [int]$chars[$i]
        $hash = ($hash + ($c * $pPow) % $m) % $m
        $pPow = ($pPow * $p) % $m
    }
    return [uint32]$hash
}

function Convert-Placeholders {
    param([string]$text)

    $index = 0
    return $script:PlaceholderPattern.Replace($text, {
        param($m)
        $result = "{$index}"
        $index++
        return $result
    })
}

# ============================================================
# Find Project Root
# ============================================================
$rootFolder = try {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if (-not $gitRoot) { throw }
    $gitRoot.Trim()
} catch {
    $PSScriptRoot
}

$outputFile = Join-Path $rootFolder $script:Config.OutputJson
$outputXmlFile = Join-Path $rootFolder $script:Config.OutputXml

# ============================================================
# Scan TwinCAT Files (Stream Processing)
# ============================================================
$scannedMessages = [System.Collections.Generic.Dictionary[uint32, psobject]]::new()
$conflictLog = [System.Collections.Generic.List[string]]::new()
$totalFiles = 0
$modifiedFiles = 0

# Process via Pipeline streaming to handle memory efficiently
Get-ChildItem -Path $rootFolder -Recurse -Include $script:Config.FileFilter -ErrorAction SilentlyContinue | ForEach-Object {
    $totalFiles++
    $file = $_
    
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        if ([string]::IsNullOrWhiteSpace($content)) { return }

        $originalContent = $content
        $content = $script:Config.MessagePattern.Replace($content, {
            param($m)

            $prefix = $m.Groups[1].Value
            $type   = $m.Groups[2].Value
            $text   = $m.Groups[3].Value.Trim()
            $idText = $m.Groups[4].Value.Trim()
            $suffix = $m.Groups[5].Value

            if ([string]::IsNullOrWhiteSpace($text)) { return $m.Value }

            [uint32]$id = 0
            $hasId = [uint32]::TryParse($idText, [ref]$id)
            $hashId = Get-UDINTHash $text

            if (-not $hasId) {
                $id = $hashId
            } elseif ($id -ne $hashId) {
                $oldId = $id
                $id = $hashId
                $conflictLog.Add("[ID $oldId -> $id] $($file.Name): '$text'")
            }

            # Thread-safe dictionary collection tracking
            if (-not $scannedMessages.ContainsKey($id)) {
                $scannedMessages[$id] = [PSCustomObject]@{ id = $id; key = $text }
            }

            return "$prefix`M_$type('$text', $id)$suffix"
        })

        if ($content -ne $originalContent) {
            [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
            $modifiedFiles++
        }
    } catch {
        Write-Log "Error processing $($file.Name): $_" "Error"
    }
}

Write-Log "Parsed $totalFiles files, found $($scannedMessages.Count) messages."
if ($modifiedFiles -gt 0) { Write-Log "Updated IDs in $modifiedFiles files." "Warning" }
if ($conflictLog.Count -gt 0) {
    Write-Log "ID corrections: $($conflictLog.Count)" "Warning"
    foreach ($c in $conflictLog) { Write-Log $c }
}

# ============================================================
# Load & Process Existing JSON
# ============================================================
$finalMessages = [System.Collections.Specialized.OrderedDictionary]::new()
$keyToIdMap = [System.Collections.Generic.Dictionary[string, uint32]]::new()
$duplicateKeyLog = [System.Collections.Generic.List[string]]::new()

if (Test-Path $outputFile) {
    try {
        $rawJson = [System.IO.File]::ReadAllText($outputFile, [System.Text.Encoding]::UTF8) | ConvertFrom-Json
        
        # PowerShell 5.1 safe fallback block for finding data node
        $rawMessages = $rawJson.Events
        if (-not $rawMessages) { $rawMessages = $rawJson.Messages }
        if (-not $rawMessages) { $rawMessages = $rawJson }

        foreach ($msg in $rawMessages) {
            $currentId = [uint32]$msg.id
            $messageKey = $msg.key.Trim()
            $correctHash = Get-UDINTHash $messageKey

            if ($keyToIdMap.ContainsKey($messageKey)) {
                $existingId = $keyToIdMap[$messageKey]
                if ($existingId -eq $correctHash) { continue }

                if ($currentId -eq $correctHash) {
                    $finalMessages.Remove($existingId)
                    $keyToIdMap[$messageKey] = $currentId
                } else {
                    continue
                }
                $duplicateKeyLog.Add("Removed duplicate ID $existingId for '$messageKey'")
            }

            $keyToIdMap[$messageKey] = $currentId

            $dict = [System.Collections.Specialized.OrderedDictionary]::new()
            foreach ($prop in $msg.PSObject.Properties) {
                if ($prop.Name -eq "source" -or $prop.Name -eq "file") { continue }
                $dict[$prop.Name] = $prop.Value
            }
            $finalMessages[$currentId] = $dict
        }
    } catch {
        Write-Log "Invalid messages.json, starting clean." "Warning"
    }
}

if ($duplicateKeyLog.Count -gt 0) {
    Write-Log "Removed $($duplicateKeyLog.Count) duplicate JSON entries." "Warning"
    foreach ($entry in $duplicateKeyLog) { Write-Log $entry }
}

# ============================================================
# Merge & Export JSON + XML
# ============================================================
$newMessagesList = [System.Collections.Generic.List[psobject]]::new()

foreach ($id in ($scannedMessages.Keys | Sort-Object)) {
    $scan = $scannedMessages[$id]

    if (-not $finalMessages.Contains($id)) {
        $newMessagesList.Add([PSCustomObject]@{ Id = Format-MessageId $id; Text = $scan.key })
        $finalMessages[$id] = [Ordered]@{
            id  = Format-MessageId $id
            key = $scan.key
        }
    }
    $finalMessages[$id]["key"] = $scan.key
}

if ($newMessagesList.Count -gt 0) {
    Write-Log "Added $($newMessagesList.Count) new messages. Total: $($finalMessages.Count)" "Warning"
    foreach ($msg in $newMessagesList) { Write-Log "NEW [$($msg.Id)] $($msg.Text)" }
}

try {
    # Generate Sorted Output Arrays
    $cleanedSortedList = [System.Collections.Generic.List[object]]::new()
    foreach ($key in ($finalMessages.Keys | Sort-Object)) {
        $messageObject = $finalMessages[$key]
        $cleanedObject = [System.Collections.Specialized.OrderedDictionary]::new()

        foreach ($prop in $messageObject.Keys) {
            $value = $messageObject[$prop]
            if ($prop -eq "source" -or $prop -eq "file") { continue }
            if ($prop -eq "id" -or $prop -eq "key") {
                $cleanedObject[$prop] = $value
                continue
            }
            if (-not [string]::IsNullOrEmpty([string]$value)) {
                $cleanedObject[$prop] = $value
            }
        }
        $cleanedSortedList.Add($cleanedObject)
    }

    # Write cleaned structured JSON
    [Ordered]@{ locale = $Languages; Events = $cleanedSortedList } | 
        ConvertTo-Json -Depth 4 | 
        Set-Content -Path $outputFile -Encoding UTF8
    
    Write-Log "Created $outputFile"

    # ========================================================
    # Structured XML Creation
    # ========================================================
    $xmlDoc = [System.Xml.XmlDocument]::new()
    [void]$xmlDoc.AppendChild($xmlDoc.CreateXmlDeclaration("1.0", "utf-8", $null))
    $root = $xmlDoc.AppendChild($xmlDoc.CreateElement("EventClass"))

    foreach ($id in ($scannedMessages.Keys | Sort-Object)) {
        $msg = $scannedMessages[$id]
        
        $event = $xmlDoc.CreateElement("EventId")
        
        $name = $xmlDoc.CreateElement("Name")
        $name.SetAttribute("Id", (Format-MessageId $msg.id))
        $name.InnerText = "Tc3_Event_$($msg.id)"
        
        $display = $xmlDoc.CreateElement("DisplayName")
        $display.SetAttribute("TxtId", "")
        [void]$display.AppendChild($xmlDoc.CreateCDataSection((Convert-Placeholders $msg.key)))

        [void]$event.AppendChild($name)
        [void]$event.AppendChild($display)
        [void]$root.AppendChild($event)
    }

    $xmlDoc.Save($outputXmlFile)
    Write-Log "Created $outputXmlFile"
    Write-Log "Done."
} catch {
    Write-Log "Export failed: $_" "Error"
}