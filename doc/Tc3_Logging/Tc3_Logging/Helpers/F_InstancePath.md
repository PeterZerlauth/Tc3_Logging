# F_InstancePath

**Type:** `FUNCTION`
**Source File:** `Tc3_Logging/Tc3_Logging/Helpers/F_InstancePath.TcPOU`

Filter instance path, to something useful

**Returns:** `STRING`

## Inputs
| Name | Type | Description |
| --- | --- | --- |
| `sInstancePath` | `STRING` |  |

## Local Variables
| Name | Type | Description |
| --- | --- | --- |
| `sInstancePath` | `STRING` |  |

## Implementation
```iec
F_InstancePath:= RIGHT(sInstancePath, LEN(sInstancePath) - FIND(sInstancePath, '.'));
F_InstancePath:= RIGHT(F_InstancePath, LEN(F_InstancePath) - FIND(F_InstancePath, '.'));

FOR nPosition:= LEN(F_InstancePath) TO 1 BY -1 DO
    IF F_InstancePath[nPosition] = 46 THEN
		F_InstancePath := LEFT(F_InstancePath, nPosition);
		RETURN;
	END_IF
END_FOR
```
