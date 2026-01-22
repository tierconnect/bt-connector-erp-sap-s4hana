# Extending the Code

## Prerequisites

**NOTE**
In order to extend the code in this sample, you will need the Eclipse IDE with ABAP Development Tools installed.

## Procedure
In the Eclipse IDE, select **File** > **New** > **ABAP Cloud Project**.

Enter the URL of your S/4HANA Public Cloud Development instance and click Next. You will be asked to Logon to your S/4HANA instance.

Enter a Project Name and click Finish.

Expand the **ZPARTNER** package. The sample code is in the **ZSEAGULL_LABEL_PRINT** package.

See the **ZCL_BARTENDER_API_CALL** class for sample code to submit a Print request to the BarTender Cloud REST API

The sample code retrieves connection information from the **ZR_SEAGULL_CRED** view. The information in this view can be managed from within the SAP UI.