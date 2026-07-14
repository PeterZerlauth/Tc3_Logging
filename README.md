# Tc3_Logging: Event Logging Framework for TwinCAT 3

[![License](https://img.shields.io/github/license/PeterZerlauth/Tc3_Logging)](LICENSE.md)
![TwinCAT](https://img.shields.io/badge/TwinCAT-3-blue)
![Platform](https://img.shields.io/badge/Platform-PLC%20Automation-green)

**Tc3_Logging** is a lightweight, high-performance event logging framework
designed for TwinCAT 3 automation projects.
It provides structured, standardized logging for diagnostics, simplifies
development, and integrates seamlessly with HMIs and SCADA systems.

------------------------------------------------------------------------

## 📚 Table of Contents

-   [Overview](#overview)
-   [Key Features](#key-features--developer-benefits)
-   [Getting Started](#getting-started)
-   [Advanced Usage](#advanced-usage)
-   [Exports](#json-export--xml-export)
-   [Screenshots](#screenshots)
-   [Roadmap](#roadmap)
-   [Contributing](#contributing)
-   [License](#license)
-   [Dual Licensing Model](#dual-licensing-model)

------------------------------------------------------------------------

## 🔍 Overview

Tc3_Logging accelerates your development cycle by 30--50% by eliminating
manual steps and implementing standardized, traceable logging from day
one.\
Built with Structured Text (ST) and reusable Function Blocks, it ensures
clarity, consistency, and operational transparency.

------------------------------------------------------------------------

## 🛠️ Key Features & Developer Benefits

  -----------------------------------------------------------------------
  Feature                 Description             Benefit
  ----------------------- ----------------------- -----------------------
  Structured Logging      Reusable Function       Easy adoption &
                          Blocks in ST            maintainability

  Automated ID Generation PowerShell script for   Faster development,
                          unique IDs              fewer errors

  Dynamic Parameters      Embed variables in logs Context-rich
                                                  diagnostics

  HMI Ready               Real-time display on    Operational clarity
                          HMIs                    

  Multi-Level             Log levels: `Verbose`,  Efficient debugging
  Traceability            `Info`, `Warning`,      
                          `Error`, `Critical`     

  Functional Logger       Dedicated component for Rapid commissioning
                          testing                 
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## ⚡ Getting Started

### 1. Clone the Repository

``` bash
git clone https://github.com/PeterZerlauth/Tc3_Logging.git
```

### 2. Import into TwinCAT 3

Add the library to your TwinCAT 3 project.

### 3. Initialize Loggers

``` pascal
PROGRAM MAIN
VAR
    fbLogger:       Tc3_Event.FB_LoggerManager;
    fbHmiLogger:    Tc3_Event.FB_HmiLogger;
    fbFileLogger:   Tc3_Event.FB_FileLogger;
    fbTcLogger:     Tc3_Event.FB_TcLogger;
END_VAR

fbLogger.M_Add(fbHmiLogger);
fbLogger.M_Add(fbFileLogger);
fbLogger.M_Add(fbTcLogger);
```

------------------------------------------------------------------------

## 🔍 Advanced Usage

``` pascal
PROGRAM MAIN
VAR
    fbEvent: FB_Event;
END_VAR

fbEvent();
fbEvent.P_Logger := fbLogger;

fbEvent.M_Verbose('Verbose');

fbEvent.M_Info(2276475569, 'System initialized');

fbEvent.M_AddREAL(33.1345321, 3);
fbEvent.M_Warning(1791326186, 'High temperature detected < %s °C');

fbEvent.M_Error(2621541999, 'Motor communication failed');

fbEvent.M_Critical(2626343866, 'Emergency stop activated');
```

------------------------------------------------------------------------

## 📤 JSON Export

``` bash
.\export.ps1 -Languages @("en", "de", "es")
```
``` json
{
    "locale":  [ "en", "de", "es" ],
    "Events":  [
                   {
                       "id":  "849363082",
                       "key":  "Input %s is simulated"
                   }
  ]
}
```


------------------------------------------------------------------------

## 📤 XML Export

``` xml
<EventClass>
  <EventId>
    <Name Id="828536003">Tc3_Event_828536003</Name>
    <DisplayName TxtId=""><![CDATA[I message {0} {1}]]></DisplayName>
  </EventId>
</EventClass>
```

------------------------------------------------------------------------

## 📸 Screenshots

------------------------------------------------------------------------
   ![HMI](https://github.com/user-attachments/assets/76e4d475-e2f1-42ff-9ccd-e3bdb786d7bc)   ![Logger](https://github.com/user-attachments/assets/b2c84339-6437-416f-bf1d-d2c682075724)   ![Trace](https://github.com/user-attachments/assets/dbc4e062-77dd-4cb7-ab16-48f9eb94d3ca)



------------------------------------------------------------------------

## 🚀 Roadmap

-   [x] Structured Logging\
-   [x] HMI Integration\
-   [x] File Logging\
-   [ ] TwinCAT Eventlogger Integration (in development)

------------------------------------------------------------------------

## 🤝 Contributing

Pull requests are welcome. For major changes, open an issue first.

------------------------------------------------------------------------

## 📝 Dual Licensing Model

Tc3_Event is distributed under a **Dual License Model** to support both
open-source usage and commercial adoption.

### 1. Open Source License (GPLv3)

-   Free for individuals, academia, and non-commercial use
-   Permits commercial use **only if** derivative works remain
    open-source under GPLv3\
-   Requires full source disclosure of modifications and derivative
    products

### 2. Commercial License

A commercial license is required for companies that:

-   Integrate Tc3_Event into proprietary, closed-source products
-   Cannot release their entire application under GPLv3
-   Need warranty, professional support, or long-term maintenance
-   Require customized licensing or integration rights

The commercial license removes GPLv3 copyleft obligations.

### Contact for Commercial Licensing

For licensing inquiries, contact:
**info@peterzerlauth.com**
