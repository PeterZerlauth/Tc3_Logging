# MAIN

**Type:** `PROGRAM`
**Source File:** `Tc3_Logging/plc01/POUs/MAIN.TcPOU`

*No documentation found.*

## Local Variables
| Name | Type | Description |
| --- | --- | --- |
| `fbLogger` | `Tc3_Logging.FB_LoggerManager` |  |
| `fbFileLogger` | `Tc3_Logging.FB_FileLogger` |  |
| `exception` | `__SYSTEM.ExceptionCode` |  |

## Implementation
```iec
__TRY
	IF exception = __SYSTEM.ExceptionCode.RTSEXCPT_NOEXCEPTION THEN
		fbLogger.M_Add(fbHmiLogger);
		fbLogger.M_Add(fbFileLogger);
			
		fbHmiLogger();
		fbFileLogger.sPathName:= 'C:\temp\log.txt';
		fbFileLogger();

		
		
		IF bReset THEN
			fbTest.P_Event.M_Reset();
		END_IF
		
		fbTest.P_Event.P_Logger:= fbLogger;
		
		fbTest();	
		
// 		fbTest1000.P_Event.P_Logger:= fbLogger;
// 		fbTest1000();
		
	END_IF

__CATCH(exception)

__ENDTRY
```
