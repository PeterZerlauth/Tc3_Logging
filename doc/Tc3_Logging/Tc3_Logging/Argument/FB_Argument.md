# FB_Argument

**Type:** `FUNCTION BLOCK`
**Source File:** `Tc3_Logging/Tc3_Logging/Argument/FB_Argument.TcPOU`

Store arguments in a single string seperated by $R

## Methods

### `M_AddBOOL` : `I_Argument`
add boolean value to arguments
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `bValue` | `BOOL` | Boolean input value |

**Implementation:**
```iec
sValue:= CONCAT(sValue, BOOL_TO_STRING(bValue));			// convert
sValue:= CONCAT(sValue, '$R');								// add separator
M_AddBOOL:= THIS^;
```

---
### `M_AddINT` : `I_Argument`
add int value to arguments
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `nValue` | `LINT` | Integer input value |

**Implementation:**
```iec
sValue:= CONCAT(sValue, CONCAT(LINT_TO_STRING(nValue), '$R'));	// add new arg
M_AddINT:= THIS^;
```

---
### `M_AddREAL` : `I_Argument`
add real value to arguments
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `fValue` | `LREAL` | Real input value |
| `nDecimals` | `USINT` | Decimals afer . |

**Implementation:**
```iec
sValue:= CONCAT(sValue, CONCAT(LREAL_TO_FMTSTR(fValue, nDecimals, TRUE), '$R'));				// add new arg
M_AddREAL:= THIS^;
```

---
### `M_AddSTRING` : `I_Argument`
add string value to arguments
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `sValue` | `STRING` |  |

**Implementation:**
```iec
THIS^.sValue:= CONCAT(THIS^.sValue, CONCAT(sValue, '$R'));				// add separator 
M_AddSTRING:= THIS^;
```

---
### `M_AddTIME` : `I_Argument`
add time value to arguments
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `tValue` | `TIME` | Time input value |

**Implementation:**
```iec
sValue:= CONCAT(sValue, CONCAT(TIME_TO_STRING(tValue), '$R'));				// add separator
M_AddTIME:= THIS^;
```

---
### `M_Clear` : `I_Argument`
Clear arguments

**Implementation:**
```iec
sValue:= '';
M_Clear:= THIS^;
```

---

## Properties

### `P_Value`
Returns the list with arguments

**Get Implementation:**
```iec
P_Value:= sValue;
```

---

