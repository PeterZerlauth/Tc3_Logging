# F_Filter

**Type:** `FUNCTION`
**Source File:** `Tc3_Logging/Tc3_Logging/Helpers/F_Filter.TcPOU`

Filter messages, if already existing

**Returns:** `BOOL`

## Inputs
| Name | Type | Description |
| --- | --- | --- |
| `fbMessage` | `FB_Message` | Input message |

## Local Variables
| Name | Type | Description |
| --- | --- | --- |
| `fbMessage` | `FB_Message` | Input message |

## Implementation
```iec
nIndex := 0;
WHILE nIndex < GVL.nBuffer DO
	// check id first, more performance than a string comparison
    IF GVL.aBuffer[nIndex].nID = fbMessage.nID THEN
		IF GVL.aBuffer[nIndex].sSource = fbMessage.sSource THEN
			GVL.aBuffer[nIndex].bActive := TRUE;
			F_Filter := TRUE;
			RETURN;  // Message found
		END_IF
    END_IF
    nIndex := nIndex + 1;
END_WHILE
```
