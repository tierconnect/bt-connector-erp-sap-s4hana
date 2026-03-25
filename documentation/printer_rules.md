## Configuring Business Rules for Printer Selection

### Description

This sample code includes an example of using business rules to determine the printer at print time. The business rules are stored in the ZSEAGULL_DOC_prt table and queried at print time to specify a printer.

The ZSEAGULL_CL_MATDOC_EVENT_CONSM class shows this on lines 36 - 49, where a material document event is consumed. The material document and printer are queried from the database, then submitted in the print request.

>The sample business rules use Plant, Storage Location, Goods Movement Type, and Document Type to determine the necessary printer.

### Configuring Printer Rules in the UI

1. The business rules for printer selection can be configured in the UI by searching for the **BarTender Print Configuration** app.

2. Click **Go** to search for any existing records, or create a new record.

3. Enter the values and click **Continue**:
- Plant
- Storage Location
- Movement Type
- Document Type

4. On the record edit screen, select the Label Format, Printer Name, and Number of Copies, then click **Save**.

>**NOTE**

>The Label Format and Printer Name select dialogs are limited to 500 records. If you have more than 500 label formats or printers in your BarTender Cloud tenant, they may not be available in these select dialogs. You may still enter the label format or printer name into the fields manually and save the record.
