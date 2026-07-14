# FB_TestSlow

**Type:** `FUNCTION BLOCK`
**Source File:** `Tc3_Logging/plc01/POUs/FB_TestSlow.TcPOU`

*No documentation found.*

## Properties

### `P_Event`
*No documentation found.*

**Get Implementation:**
```iec
P_Event ref= fbEvent;
```

---

## Implementation
```iec
fbEvent();

// Demonstration of FB_Event usage with various log levels and argument types

IF bVerbose THEN
	fbEvent.P_Argument.M_AddINT(134052566194980000);
	fbEvent.P_Argument.M_AddSTRING('mm');
	fbEvent.M_Verbose('V message %s %s');
END_IF

IF bInfo THEN
	fbEvent.P_Argument.M_AddREAL(33.0, 3);
	fbEvent.P_Argument.M_AddSTRING('mm');
	fbEvent.M_Info('I message %s %s', 828536003);
END_IF

IF bWarning THEN
	fbEvent.M_Warning('W message', 475719253);
	fbEvent.M_Warning('B message', 475719232);
	fbEvent.M_Warning('B messagex', 110769791);
	fbEvent.M_Warning('C messagex', 110769792);	
	fbEvent.M_Warning('X messagex', 110769813);	
END_IF


IF bError THEN
	fbEvent.M_Error('E message', 475719235);
END_IF

IF bCritical THEN
	fbEvent.M_Error('Input %s is simulated1', 361230260);
	fbEvent.M_Error('Input %s is simulated', 849363082);
	fbEvent.M_Error('Input %s is simulated2', 820656125);
	fbEvent.M_Error('Input %s is simulated2', 820656125);
END_IF
```
