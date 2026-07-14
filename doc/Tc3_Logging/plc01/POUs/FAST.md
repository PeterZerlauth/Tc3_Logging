# FAST

**Type:** `PROGRAM`
**Source File:** `Tc3_Logging/plc01/POUs/FAST.TcPOU`

*No documentation found.*

## Local Variables
| Name | Type | Description |
| --- | --- | --- |
| `fbTest` | `FB_TestFast` |  |

## Implementation
```iec
__TRY
	IF exception = __SYSTEM.ExceptionCode.RTSEXCPT_NOEXCEPTION THEN
		fbTest.P_Event.P_Logger:= MAIN.fbLogger;
	
	fbTest();
	
		
	END_IF


__CATCH(exception)


__ENDTRY
```
