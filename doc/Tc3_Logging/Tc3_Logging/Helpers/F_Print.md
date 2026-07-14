# F_Print

**Type:** `FUNCTION`
**Source File:** `Tc3_Logging/Tc3_Logging/Helpers/F_Print.TcPOU`

Helper to generate a message with replaced arguments

**Returns:** `STRING`

## Inputs
| Name | Type | Description |
| --- | --- | --- |
| `sMessage` | `STRING` |  |
| `sArguments` | `STRING` |  |

## Local Variables
| Name | Type | Description |
| --- | --- | --- |
| `sMessage` | `STRING` |  |
| `sArguments` | `STRING` |  |

## Implementation
```iec
// replace placeholders with arguments
F_Print := sMessage;

IF sArguments = '' THEN
    RETURN;
END_IF

nPosition := FIND(sArguments, '$R');
WHILE nPosition > 0 DO
    
    sArg := LEFT(sArguments, nPosition - 1);
    
    nPlaceholder := FIND(F_Print, '%s');
    IF nPlaceholder > 0 THEN
        F_Print := REPLACE(F_Print, sArg, 2, nPlaceholder);
    ELSE
        RETURN;
    END_IF
	
    sArguments := DELETE(sArguments, nPosition, 1);
    nPosition := FIND(sArguments, '$R');
    
END_WHILE
```
