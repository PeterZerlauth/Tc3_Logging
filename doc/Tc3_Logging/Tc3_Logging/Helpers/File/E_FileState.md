# E_FileState

**Type:** `ENUM`
**Source File:** `Tc3_Logging/Tc3_Logging/Helpers/File/E_FileState.TcDUT`

*No documentation found.*

## Declaration
```iec
{attribute 'qualified_only'}
{attribute 'strict'}
{attribute 'to_string'}
TYPE E_FileState :
(
    OK := 0,             // File could be opened
    NO_FILE := 1,        // No file available
    ILLEGAL_POS := 2,    // Illegal position in the file
    FULL := 3,           // No more space on the filesystem
    EOF := 4             // End of file reached
) UDINT;
END_TYPE
```
