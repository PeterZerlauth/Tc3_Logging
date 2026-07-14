# FB_FileLogger

**Type:** `FUNCTION BLOCK`
**Source File:** `Tc3_Logging/Tc3_Logging/Logger/FileLogger/FB_FileLogger.TcPOU`

Provide logging

## Inputs
| Name | Type | Description |
| --- | --- | --- |
| `sPathName` | `STRING` |  |

## Local Variables
| Name | Type | Description |
| --- | --- | --- |
| `sPathName` | `STRING` |  |

## Methods

### `M_Log` : `BOOL`
*No documentation found.*
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `fbMessage` | `FB_Message` |  |

**Implementation:**
```iec
// Log Level
IF eLogLevel > fbMessage.eLogLevel THEN
	M_Log:= TRUE;
	RETURN;
END_IF

nTimestamp:= fbMessage.nTimestamp;

// Skip if message already in buffer
nIndex := 0;
WHILE nIndex < nBuffer DO
	// check id first, more performance than a string comparison
    IF aBuffer[nIndex].nID = fbMessage.nID THEN
		IF aBuffer[nIndex].sSource = fbMessage.sSource THEN
			aBuffer[nIndex].bActive := TRUE;
			RETURN;  // Message found
		END_IF
    END_IF
    nIndex := nIndex + 1;
END_WHILE


// Add new message
IF nBuffer < 99 THEN
    aBuffer[nBuffer] := fbMessage;
    nBuffer := nBuffer + 1;
END_IF

// Format log line
stTimestamp:= FILETIME64_TO_SYSTEMTIME(fbMessage.nTimestamp);

// Year
sLogLine := CONCAT('[', WORD_TO_DECSTR(stTimestamp.wYear, 4));
sLogLine := CONCAT(sLogLine, '-');
sLogLine := CONCAT(sLogLine, WORD_TO_DECSTR(stTimestamp.wMonth, 2));
sLogLine := CONCAT(sLogLine, '-');
sLogLine := CONCAT(sLogLine, WORD_TO_DECSTR(stTimestamp.wDay, 2));
sLogLine := CONCAT(sLogLine, 'T');

// Time
sLogLine := CONCAT(sLogLine, WORD_TO_DECSTR(stTimestamp.wHour, 2));
sLogLine := CONCAT(sLogLine, ':');
sLogLine := CONCAT(sLogLine, WORD_TO_DECSTR(stTimestamp.wMinute, 2));
sLogLine := CONCAT(sLogLine, ':');
sLogLine := CONCAT(sLogLine, WORD_TO_DECSTR(stTimestamp.wSecond, 2));
sLogLine := CONCAT(sLogLine, '.');
sLogLine := CONCAT(sLogLine, WORD_TO_DECSTR(stTimestamp.wMilliseconds, 3));


sLogLine := CONCAT(sLogLine, '] ');
sLogLine := CONCAT(sLogLine, TO_STRING(fbMessage.eLogLevel));
sLogLine := CONCAT(sLogLine, ' [');
sLogLine := CONCAT(sLogLine, UDINT_TO_STRING(fbMessage.nID));
sLogLine := CONCAT(sLogLine, '] ');
sLogLine := CONCAT(sLogLine, fbMessage.sDefault);
sLogLine := CONCAT(sLogLine, '$R$N');

// Write once per new message
fbFile.M_Open(sPathName);
fbFile.M_Write(ADR(sLogLine), INT_TO_UINT(LEN(sLogLine)));
fbFile.M_Close();

// Remove expired messages (>1 s old)
// just once a cycle
IF nTimestamp <> fbMessage.nTimestamp THEN
	nTimestamp:= fbMessage.nTimestamp;
	// Remove outdated messages
	WHILE nIndex < nBuffer DO
		IF (nTimestamp - aBuffer[nIndex].nTimestamp) > 1_000_000_000 THEN // 1 s = 1e9 ns
			// Shift remaining messages down
			MEMMOVE(ADR(aBuffer[nIndex]), ADR(aBuffer[nIndex + 1]), SIZEOF(FB_Message) * (nBuffer - nIndex - 1));
			nBuffer := nBuffer - 1;
		ELSE
			nIndex := nIndex + 1;
		END_IF
	END_WHILE
END_IF

M_Log := TRUE;
```

---
### `M_Reset` : `BOOL`
*No documentation found.*

**Implementation:**
```iec
M_Reset:= TRUE;
```

---

## Properties

### `P_LogLevel`
*No documentation found.*

**Get Implementation:**
```iec
P_LogLevel:= eLogLevel;
```
**Set Implementation:**
```iec
eLogLevel:= P_LogLevel;
```

---

## Implementation
```iec
// https://peterzerlauth.com/
```
