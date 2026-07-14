# LogLevel_To_Severity

**Type:** `FUNCTION`
**Source File:** `Tc3_Logging/Tc3_Logging/Helpers/LogLevel_To_Severity.TcPOU`

Converts internal loglevel to twincat severity

**Returns:** `TcEventSeverity`

## Inputs
| Name | Type | Description |
| --- | --- | --- |
| `eLogLevel` | `E_LogLevel` |  |

## Local Variables
| Name | Type | Description |
| --- | --- | --- |
| `eLogLevel` | `E_LogLevel` |  |

## Implementation
```iec
CASE eLogLevel OF
	E_LogLevel.Verbose:
		LogLevel_To_Severity:= TcEventSeverity.Verbose;
		
	E_LogLevel.Info:
		LogLevel_To_Severity:= TcEventSeverity.Info;
		
	E_LogLevel.Warning:
		LogLevel_To_Severity:= TcEventSeverity.Warning;
		
	E_LogLevel.Error:
		LogLevel_To_Severity:= TcEventSeverity.Error;
		
	E_LogLevel.Critical:
		LogLevel_To_Severity:= TcEventSeverity.Critical;
		
END_CASE
```
