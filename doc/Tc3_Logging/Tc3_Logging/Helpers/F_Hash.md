# F_Hash

**Type:** `FUNCTION`
**Source File:** `Tc3_Logging/Tc3_Logging/Helpers/F_Hash.TcPOU`

Calculate hash value, same as the posershell sript

**Returns:** `UDINT`

## Inputs
| Name | Type | Description |
| --- | --- | --- |
| `sInput` | `STRING` |  |

## Local Variables
| Name | Type | Description |
| --- | --- | --- |
| `sInput` | `STRING` |  |

## Implementation
```iec
nLength:= Len(sInput);
FOR nIndex := 0 TO nLength DO
	nValue := sInput[nIndex];
    nHash := (nHash + (nValue * nPow MOD nModulo)) MOD nModulo;
    nPow := (nPow * nPower) MOD nModulo;
END_FOR

F_Hash:= Ulint_to_Udint(nHash);
```
