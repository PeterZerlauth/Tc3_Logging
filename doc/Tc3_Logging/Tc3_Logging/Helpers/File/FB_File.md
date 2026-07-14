# FB_File

**Type:** `FUNCTION BLOCK`
**Source File:** `Tc3_Logging/Tc3_Logging/Helpers/File/FB_File.TcPOU`

SysFile from codesys

## Outputs
| Name | Type | Description |
| --- | --- | --- |
| `pBuffer` | `POINTER` |  |
| `nBuffer` | `UDINT` |  |

## Methods

### `FB_Exit` : `BOOL`
FB_Exit must be implemented explicitly. If there is an implementation, then the
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `bInCopyCode` | `BOOL` | TRUE: the exit method is called in order to leave the instance which will be copied afterwards (online change). |

**Implementation:**
```iec
M_Reset();
```

---
### `M_Close` : `BOOL`
Closes the file if opened

**Implementation:**
```iec
IF hFile > 0 THEN
   nResult:= SysFile.SysFileClose(hFile);
   IF nResult = 0 THEN
	   hFile:= 0;
	   M_Close:= TRUE;
   ELSE
	    bError := TRUE;
   END_IF
END_IF
```

---
### `M_Delete` : `BOOL`
Delete file
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `sFileName` | `STRING` |  |

**Implementation:**
```iec
IF hFile > 0 THEN
	M_Close();
END_IF

nResult:= SysFile.SysFileDelete(sFileName);
IF nResult = 0 THEN
	M_Delete:= TRUE;
ELSE
    bError := TRUE;
END_IF
```

---
### `M_GetSize` : `UDINT`
Get file size

**Implementation:**
```iec
M_GetSize:= LWORD_TO_UDINT(SysFile.SysFileGetSize(sFileName, pResult));

IF nResult <> 0 THEN
	bError := TRUE;
END_IF
```

---
### `M_Open` : `BOOL`
Open file
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `sFileName` | `STRING` |  |
| `eMode` | `SysFile.ACCESS_MODE` |  |

**Implementation:**
```iec
IF hFile = 0 THEN
	THIS^.eMode:= eMode;
	hFile := SysFile.SysFileOpen(sFileName, eMode, pResult);
	IF hFile = SysFile.SysTypes.RTS_INVALID_HANDLE  THEN
		bError := TRUE;
		RETURN;
	END_IF

   IF nResult = 0 THEN
	   THIS^.sFileName:= sFileName;
	   M_Open:= TRUE;
   ELSE
	    bError := TRUE;
   END_IF
ELSE 
	IF THIS^.sFileName = sFileName THEN
		M_Open:= TRUE;
	END_IF
END_IF
```

---
### `M_Read` : `BOOL`
Read file

**Implementation:**
```iec
IF pBuffer <> 0 THEN
	__DELETE(pBuffer);
	nBuffer:= 0;
END_IF

nBuffer:= M_GetSize();

IF nBuffer > 0 THEN
    pBuffer:= __NEW(BYTE, nBuffer);
	IF pBuffer = 0 THEN
		RETURN;
	END_IF
END_IF

IF M_Read = 0 THEN
	M_Read := TRUE;
ELSE
	bError:= TRUE;
END_IF
```

---
### `M_Reset` : `BOOL`
Reset all

**Implementation:**
```iec
IF pBuffer <> 0 THEN
	__DELETE(pBuffer);
	nBuffer:= 0;
END_IF

M_Close();

bError:= FALSE;
M_Reset:= TRUE;
```

---
### `M_Status` : `E_FileState`
File status

**Implementation:**
```iec
bError := FALSE;
nResult := 0; // This function does not use pResult

IF hFile < 0 THEN
   nState := SysFile.SysFileGetStatus(hFile);
   CASE nState OF
	   SysFile.SYS_FILE_STATUS.FS_OK:
   			M_Status:= E_FileState.OK;
			
	   SysFile.SYS_FILE_STATUS.FS_NO_FILE:
			M_Status:= E_FileState.NO_FILE;
			
	   SysFile.SYS_FILE_STATUS.FS_ILLEGAL_POS:
			M_Status:= E_FileState.ILLEGAL_POS;   
			
	   SysFile.SYS_FILE_STATUS.FS_FULL:
			M_Status:= E_FileState.FULL; 
			
	   SysFile.SYS_FILE_STATUS.FS_EOF:   
			M_Status:= E_FileState.EOF;
 
   END_CASE
   
END_IF
```

---
### `M_Write` : `BOOL`
Writes content to a file
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `pBuffer` | `POINTER` |  |
| `nSize` | `UDINT` |  |

**Implementation:**
```iec
IF pBuffer = 0 OR nSize = 0 THEN
    RETURN;
END_IF

IF hFile > 0 THEN
	SysFile.SysFileWrite(hFile := hFile, pbyBuffer := pBuffer, ulSize := nSize, pResult := pResult);
END_IF

IF nResult = 0 THEN
	M_Write := TRUE;
ELSE
	bError:= TRUE;
END_IF
```

---

## Implementation
```iec
// https://peterzerlauth.com/
```
