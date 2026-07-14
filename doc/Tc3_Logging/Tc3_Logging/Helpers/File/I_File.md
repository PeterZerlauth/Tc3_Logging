# I_File

**Type:** `INTERFACE`
**Source File:** `Tc3_Logging/Tc3_Logging/Helpers/File/I_File.TcIO`

*No documentation found.*

## Methods

### `M_Close` : `BOOL`
close file

---
### `M_Delete` : `BOOL`
Delete file
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `sFileName` | `STRING` |  |

---
### `M_GetSize` : `UDINT`
get file size

---
### `M_Open` : `BOOL`
Open file
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `sFileName` | `STRING` |  |
| `eMode` | `SysFile.ACCESS_MODE` |  |

---
### `M_Read` : `BOOL`
Read file

---
### `M_Status` : `E_FileState`
state of file

---
### `M_Write` : `BOOL`
Write file
**Inputs:**
| Name | Type | Description |
| --- | --- | --- |
| `pBuffer` | `POINTER` |  |
| `nSize` | `UDINT` |  |

---

