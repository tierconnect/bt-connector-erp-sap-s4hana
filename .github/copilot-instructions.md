# BarTender Cloud SAP S/4HANA Connector - Development Guide

## Overview

This is an ABAP plugin for SAP S/4HANA Cloud Public Edition that integrates with BarTender Cloud REST APIs to enable automated label printing. The plugin queries SAP CDS views, serializes data to JSON, and submits print jobs to BarTender Cloud in response to business events or manual user requests.

## Development Environment

- **IDE**: Eclipse with ABAP Development Tools (ADT)
- **Target**: SAP S/4HANA Cloud Public Edition
- **Version Control**: gCTS (Git-Enabled Change and Transport System)
- **Package**: ZSEAGULL_LABEL_PRINT

## Architecture

### RAP (RESTful ABAP Programming) Structure

This plugin follows the RAP programming model with a clear layering:

- **R_ prefix**: Restricted (Interface) CDS views - define the data model
- **C_ prefix**: Consumption (Projection) CDS views - define the UI projection
- **ZBP_R_ prefix**: Behavior implementations for restricted views
- **ZBP_C_ prefix**: Behavior implementations for consumption views
- **ZUI_ prefix**: Service definitions for OData V4 services

### Key Components

1. **API Integration Layer**
   - `ZSEAGULL_CL_API_CALL`: Core class for BarTender Cloud REST API calls
     - `get_bearer_token()`: OAuth2 authentication with BarTender Cloud
     - `get_printer_dtl()`: Retrieves available printers
     - `get_label_format()`: Retrieves label templates (with pagination)
     - `post_print_info()`: Submits print jobs with JSON data overrides

2. **Event Consumer**
   - `ZSEAGULL_CL_MATDOC_EVENT_CONSM`: Consumes material document events from S/4HANA
   - Implements `FOR EVENTS OF I_materialdocumenttp`
   - Queries printer rules and submits print jobs based on business rules

3. **Configuration Data Models**
   - **Credentials**: `ZR_SEAGULL_CRED` / `ZC_SEAGULL_CRED` - BarTender Cloud authentication
   - **Print Configuration**: `ZR_SEAGULL_PRT_CFG` / `ZC_SEAGULL_PRT_CFG` - Printer selection rules
   - **Document Print**: `ZR_SEAGULL_DOC_PRT` / `ZC_SEAGULL_DOC_PRT` - Print job tracking

4. **Value Help Providers**
   - `ZSEAGULL_CL_VH_PRINTERID`: Dynamic value help for printer selection
   - `ZSEAGULL_CL_VH_LABELFORMAT`: Dynamic value help for label format selection

5. **Fiori Apps**
   - Located in `/src/objects/WAPA/`
   - Z_SEAGULL_CRED: Manage BarTender Cloud credentials
   - ZSEAGULL_PRTCFG: Configure printer selection rules
   - ZSEAGULL_DOCPRT: View print job history

### Database Tables

- `ZSEAGULL_CRED`: Stores OAuth2 credentials and tenant endpoints
- `ZSEAGULL_PRT_CFG`: Business rules for printer selection (Plant, Storage Location, Movement Type, Document Type)
- `ZSEAGULL_DOC_PRT`: Print job audit trail

## Code Conventions

### BarTender Cloud Endpoint Configuration

**IMPORTANT**: The BarTender Cloud endpoint URL is hard-coded in 3 locations in `ZSEAGULL_CL_API_CALL`:
- Line 102: Label format retrieval
- Line 162: Printer list retrieval  
- Line 332: Print job submission

When deploying to a new tenant, these URLs must be updated with the correct organization name and datacenter ID:
```abap
https://<organizationName>.<dataCenterId>.bartendercloud.com/
```

### JSON Serialization Pattern

The plugin uses `/ui2/cl_json=>name_mappings` to map ABAP field names to JSON property names (typically PascalCase). When adding new data fields:

1. Define the ABAP structure with lowercase field names
2. Create name mappings for JSON serialization
3. Use `/ui2/cl_json=>serialize()` with the mappings

Example:
```abap
DATA(lt_mappings) = VALUE /ui2/cl_json=>name_mappings(
  ( abap = 'fieldname' json = 'FieldName' )
).
```

### Printer Selection Rules

The printer selection logic (in `ZSEAGULL_CL_MATDOC_EVENT_CONSM`) queries `ZSEAGULL_DOC_PRT` table based on:
- Plant (Werks)
- Storage Location (Lgort)
- Goods Movement Type (Bwart)
- Document Type (Blart)

To extend with additional selection criteria, update both the database table and the query logic.

### Embedded Database Setup for Label Templates

Label templates in BarTender must be configured with an **Embedded JSON Database Connection** containing sample data that matches the structure sent from S/4HANA. To get the sample JSON:

1. Set a breakpoint in `post_print_info` method in Eclipse ADT
2. Copy the serialized JSON from the debugger
3. In BarTender Designer: Database Fields → Database Connection Setup → JSON → Embedded sample data
4. Paste the sample JSON and complete the setup
5. The database name (default: "JSON") must match the `DatabaseConnection` parameter in line 321 of `ZSEAGULL_CL_API_CALL`

## Known Limitations

- Value help dialogs for label formats and printers are limited to 500 records
- BarTender Cloud endpoint URL must be manually updated in 3 locations when changing tenants
- The plugin uses the first record from `ZSEAGULL_CRED` table for authentication (only one active configuration supported)

## Installation & Deployment

This plugin is deployed using gCTS (Git-Enabled Change and Transport System):

1. Import to Development system via gCTS (clone repository with "Provided" role)
2. Test in Test system (repeat gCTS clone process)
3. Deploy to Production system (repeat gCTS clone process)

**Never use Eclipse ADT for manual actions** like publishing service bindings during deployment - let gCTS handle activation automatically.

## Integration Points

- **S/4HANA CDS Views**: Queries material document data via standard CDS views
- **Business Events**: Subscribes to material document creation/update events
- **BarTender Cloud REST API**: OAuth2 authentication + print job submission
- **SAP Fiori**: Three custom apps for configuration and monitoring

## Testing

When cloning or pulling commits, wait for automatic activation (including service binding publication) to complete before testing the apps in the Fiori launchpad.

## Documentation References

- `documentation/importing_code.md`: gCTS setup and repository connection
- `documentation/configuring_plugin.md`: Credentials and endpoint configuration  
- `documentation/extending_code.md`: Adding new data fields and label templates
- `documentation/printer_rules.md`: Configuring business rules for printer selection
- `documentation/registering_application.md`: BarTender Cloud app registration
