# F_Remove

**Type:** `FUNCTION`
**Source File:** `Tc3_Logging/Tc3_Logging/Helpers/F_Remove.TcPOU`

Removes outdated messages from the buffer

**Returns:** `BOOL`

## Implementation
```iec
// just once a cycle
IF GVL.nFunction <> GVL.nTimestamp THEN
	GVL.nFunction:= GVL.nTimestamp;
	// Remove outdated messages
	WHILE nIndex < GVL.nBuffer DO
		IF (GVL.nTimestamp - GVL.aBuffer[nIndex].nTimestamp) > 1_000_000_000 THEN // 1 s = 1e9 ns
			// Shift remaining messages down
			MEMMOVE(ADR(GVL.aBuffer[nIndex]), ADR(GVL.aBuffer[nIndex + 1]), SIZEOF(FB_Message) * (GVL.nBuffer - nIndex - 1));
			GVL.nBuffer := GVL.nBuffer - 1;
			F_Remove := TRUE;
		ELSE
			nIndex := nIndex + 1;
		END_IF
	END_WHILE
END_IF
```
