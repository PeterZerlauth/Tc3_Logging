# FB_HmiLogger

**Type:** `FUNCTION BLOCK`
**Source File:** `Tc3_Logging/Tc3_Logging/Logger/HmiLogger/FB_HmiLogger.TcPOU`

Provide logging

## Local Variables
| Name | Type | Description |
| --- | --- | --- |
| `eLogLevel` | `E_LogLevel` |  |
| `aMessages` | `ARRAY` |  |
| `nMessages` | `UINT` |  |
| `nIndex` | `UINT` |  |
| `nTimestamp` | `LINT` |  |

## Methods

### `M_Log` : `BOOL`
*No documentation found.*
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `fbMessage` | `FB_Message` |  |

**Implementation:**
```iec
// 555652537:= F_Hash('###Reset###');
IF fbMessage.nID = 555652537 THEN
	// handle reset
	M_Log:= M_Reset();
	RETURN;
END_IF


IF eLogLevel > fbMessage.eLogLevel THEN
	M_Log:= TRUE;
	RETURN;
END_IF

IF nMessages > 99 THEN 
	RETURN;
END_IF

// Skip if same sMessage already exists
nIndex := 0;
WHILE nIndex < nMessages DO
    IF aMessages[nIndex].nID = fbMessage.nID THEN
		IF aMessages[nIndex].sSource = fbMessage.sSource THEN
			aMessages[nIndex].bActive:= TRUE;
			M_Log := TRUE;
			RETURN; // message already in buffer
		END_IF
    END_IF
    nIndex := nIndex + 1;
END_WHILE


aMessages[nMessages]:= fbMessage;;
nMessages := nMessages + 1;
M_Log := TRUE;
```

---
### `M_Reset` : `BOOL`
*No documentation found.*

**Implementation:**
```iec
nIndex := 0;
WHILE nIndex < nMessages DO
    IF aMessages[nIndex].bActive = TRUE THEN
		aMessages[nIndex].bActive:= FALSE;
    END_IF
    nIndex := nIndex + 1;
END_WHILE
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

IF nTimestamp < TwinCAT_SystemInfoVarList._TaskInfo[GETCURTASKINDEXEX()].DcTaskTime THEN // 1 second = 1e9 ns
	nTimestamp := TwinCAT_SystemInfoVarList._TaskInfo[GETCURTASKINDEXEX()].DcTaskTime + 1000000000;
	nIndex:= 0;
	WHILE nIndex < nMessages DO
		IF aMessages[nIndex].bActive THEN
			IF aMessages[nIndex].eLogLevel <= E_LogLevel.Warning THEN
				aMessages[nIndex].bActive:= FALSE;
			END_IF
			nIndex := nIndex + 1;
		ELSE
			MEMMOVE(ADR(aMessages[nIndex]), ADR(aMessages[nIndex + 1]), SIZEOF(FB_Message) * (nMessages - nIndex));
			nMessages := nMessages - 1;
		END_IF
	END_WHILE
END_IF
```
