# FB_TcLogger

**Type:** `FUNCTION BLOCK`
**Source File:** `Tc3_Logging/Tc3_Logging/Logger/TcLogger/FB_TcLogger.TcPOU`

*No documentation found.*

## Methods

### `M_Log` : `BOOL`
*No documentation found.*
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `fbMessage` | `FB_Message` |  |

**Implementation:**
```iec
// --- Build log line
sMessage:= CONCAT(fbMessage.sSource, ': ');
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

M_Log:= TRUE;
```

---

