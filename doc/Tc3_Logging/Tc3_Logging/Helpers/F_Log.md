# F_Log

**Type:** `FUNCTION`
**Source File:** `Tc3_Logging/Tc3_Logging/Helpers/F_Log.TcPOU`

Standalone logger, if no logger is attached to FB_Event, nice for tessting

**Returns:** `BOOL`

## Inputs
| Name | Type | Description |
| --- | --- | --- |
| `fbMessage` | `REFERENCE` |  |

## Local Variables
| Name | Type | Description |
| --- | --- | --- |
| `fbMessage` | `REFERENCE` |  |

## Implementation
```iec
// --- Build log line
sMessage:= CONCAT('Logger null | ', fbMessage.sSource);
sMessage:= CONCAT(sMessage, ': ');
sMessage:= CONCAT(sMessage, fbMessage.sDefault);

// --- Keep active
IF F_Filter(fbMessage) THEN 
	RETURN;
END_IF

// --- Add to buffer ---
IF GVL.nBuffer < 99 THEN
    GVL.aBuffer[GVL.nBuffer]:= fbMessage;
    GVL.aBuffer[GVL.nBuffer].nTimestamp := GVL.nTimestamp;
    GVL.nBuffer := GVL.nBuffer + 1;
END_IF

// --- Log message ---
CASE fbMessage.eLogLevel OF
    E_LogLevel.Verbose, E_LogLevel.Info:
        ADSLOGSTR(ADSLOG_MSGTYPE_HINT, '%s', sMessage);
    E_LogLevel.Warning:
        ADSLOGSTR(ADSLOG_MSGTYPE_WARN, '%s', sMessage);
    E_LogLevel.Error, E_LogLevel.Critical:
        ADSLOGSTR(ADSLOG_MSGTYPE_ERROR, '%s', sMessage);
END_CASE

// --- Remove outdated messages
F_Remove();

F_Log := TRUE;
```
