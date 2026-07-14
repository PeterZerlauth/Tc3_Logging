# FB_LoggerManager

**Type:** `FUNCTION BLOCK`
**Source File:** `Tc3_Logging/Tc3_Logging/Logger/Manager/FB_LoggerManager.TcPOU`

Provide the functionality to use more than one Logger target

## Local Variables
| Name | Type | Description |
| --- | --- | --- |
| `nLength` | `INT` |  |
| `aList` | `POINTER` |  |

## Methods

### `FB_exit` : `BOOL`
*No documentation found.*
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `bInCopyCode` | `BOOL` | if TRUE, the exit method is called for exiting an instance that is copied afterwards (online change). |

**Implementation:**
```iec
M_Clear();
```

---
### `M_Add` : `BOOL`
*No documentation found.*
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `iLogger` | `I_Logger` |  |

**Implementation:**
```iec
IF iLogger <> 0 THEN
	// First Item
	IF pList = 0 THEN
		nLength:= nLength + 1;
		pList:= __NEW(POINTER TO I_Logger, DINT_TO_UDINT(nLength));
	ELSE
		// Item already in List
		IF M_Find(iLogger) = -1 THEN
			// backup 
			pOldList:= pList;
			// new Length
			nLength:= nLength + 1;
			// new pointer
			pList:= __NEW(POINTER TO I_Logger, DINT_TO_UDINT(nLength));
			// restore
			Memcpy(pList, pOldList, SIZEOF(pList) * DINT_TO_UDINT(nLength -1));
			// delete old
			__DELETE(pOldList);
		ELSE
			M_Add:= FALSE;	
			RETURN;
		END_IF
	END_IF
	IF pList = 0 THEN
		RETURN;
	END_IF
	// add new Object
	pList[nLength-1]:= iLogger;
	M_Add:= TRUE;
ELSE
	M_Add:= FALSE;	
END_IF
```

---
### `M_Clear` : `bool`
*No documentation found.*

**Implementation:**
```iec
IF pList <> 0 THEN
	nLength:= 0;
	__DELETE(pList);
END_IF
M_Clear:= TRUE;
```

---
### `M_Find` : `DINT`
*No documentation found.*
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `iLogger` | `I_Logger` |  |

**Implementation:**
```iec
// Object already in List
M_Find := -1;
WHILE nIndex < nLength DO
    IF (pList[nIndex] = iLogger) THEN
        M_Find := nIndex;
        RETURN;
    END_IF
	nIndex := nIndex + 1;
END_WHILE
```

---
### `M_Index` : `I_Logger`
*No documentation found.*
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `nIndex` | `DINT` |  |

**Implementation:**
```iec
IF (nIndex < nLength) THEN
	M_Index := pList[nIndex];
END_IF
```

---
### `M_Log` : `BOOL`
*No documentation found.*
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `fbMessage` | `FB_Message` |  |

**Implementation:**
```iec
WHILE nIndex < nLength DO
    pList[nIndex].M_Log(fbMessage);
	nIndex := nIndex + 1;
END_WHILE
```

---
### `M_Remove` : `BOOL`
*No documentation found.*
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `iLogger` | `I_Logger` |  |

**Implementation:**
```iec
IF iLogger <> 0 THEN
	// First Item
	IF nLength >= 0 THEN
		// Item already in List
		nPosition:= M_Find(iLogger);
		IF nPosition <> -1 THEN
			// backup 
			pOldList:= pList;
			// new Length
			nLength:= nLength -1;
			// new pointer
			pList:= __NEW(POINTER TO I_Logger ,DINT_TO_UDINT(nLength));
			// restore lower part
			Memcpy(pList, pOldList, SIZEOF(pList) * DINT_TO_UDINT(nPosition));
			//pList[nPosition]:= iObject;
			Memcpy(pList + (SIZEOF(pList) * nPosition),pOldList + (SIZEOF(pList)*(nPosition + 1)), SIZEOF(pList) * DINT_TO_UDINT(nLength - nPosition));
			// delete old
			__DELETE(pOldList);
		ELSE
			M_Remove:= FALSE;	
			RETURN;
		END_IF
	ELSE
		M_Remove:= FALSE;	
		RETURN;
	END_IF
	M_Remove:= TRUE;
ELSE
	M_Remove:= FALSE;	
END_IF
```

---
### `M_Reset` : `BOOL`
*No documentation found.*

**Implementation:**
```iec
fbReset.bActive:= TRUE;
fbReset.sMessage:= '###Reset###';
fbReset.eLogLevel:= E_LogLevel.Error;
fbReset.nID:= F_Hash(fbReset.sMessage);
fbReset.nTimestamp:= 0;
fbReset.sArguments:= '';
fbReset.sDefault:= '';
fbReset.sSource:= '';
fbReset.sType:= 'FB_LoggerManager';

nIndex := 0;
M_Reset:= TRUE;
WHILE nIndex < nLength DO
    IF pList[nIndex].M_Log(fbReset) THEN
		;
	ELSE
		M_Reset:= FALSE;
	END_IF
    nIndex := nIndex + 1;
END_WHILE
```

---

## Properties

### `P_Length`
*No documentation found.*

**Get Implementation:**
```iec
P_Length:= nLength;
```

---

