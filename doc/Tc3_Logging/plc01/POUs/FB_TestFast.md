# FB_TestFast

**Type:** `FUNCTION BLOCK`
**Source File:** `Tc3_Logging/plc01/POUs/FB_TestFast.TcPOU`

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
	fbEvent.P_Argument.M_AddREAL(33.134581234, 3);
	fbEvent.P_Argument.M_AddSTRING('mm');
	fbEvent.M_Info('I message %s %s', 828536003);
END_IF

IF bWarning THEN
	fbEvent.M_Warning('W message', 475719253);
	fbEvent.M_Warning('W message', 475719253);
END_IF

IF bError THEN
	fbEvent.M_Error('E message', 475719235);
END_IF

IF bCritical THEN
	fbEvent.M_Critical('C message', 475719233);//475719234
	fbEvent.M_Critical('B message', 475719232); 
END_IF
```
