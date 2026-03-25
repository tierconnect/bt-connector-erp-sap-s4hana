# Extending the Code

## Prerequisites

>**NOTE**
>
>In order to extend the code in this sample, you will need to install the Eclipse IDE with ABAP Development Tools.

## Procedure

1. In the Eclipse IDE, select **File** > **New** > **ABAP Cloud Project**.

2. Enter the URL of your S/4HANA Public Cloud Development instance and click **Next**. You will be asked to Logon to your S/4HANA instance.

3. Enter a Project Name and click **Finish**.

4. Expand the ZPARTNER package. The sample code is in the ZSEAGULL_LABEL_PRINT package.

5. See the ZSEAGULL_CL_API_CALL class for sample code to submit a Print request to the BarTender Cloud REST API.

6. The sample code retrieves connection information from the ZR_SEAGULL_CRED view. The information in this view can be managed from within the SAP UI.

The sample code demonstrates serializing a database view to JSON, such as the Material Document Header and Item view in the sample, and submits a print request to the API by passing in the serialized JSON as a database override. See the post_print_info method for sample.

In order to pass the serialized JSON data to a print job, the label template must be configured with an Embedded Database Connection with a sample of the JSON data. It is recommended to copy a sample of the JSON data from the debugger in Eclipse for use in the BarTender Label Template.

## Setting up the Embedded Database in your BarTender Label Template

Either create a new label, or open an existing label in the BarTender Label Designer.

1. In the Data Sources section on the left, right-click **Database Fields** and select **Database Connection Setup...**

2. Select **JSON** as the database type and click **Next**.

3. Select **Embedded sample data** and click **Next**.

4. Paste your sample JSON data selected from the debugger earlier, and click **Next**.

5. Click **Next** and then **Finish**. The JSON database fields are now available for use in your Label Design.

The default database name is JSON and can be changed by right-clicking the **Database Fields** option and selecting **Database Connection Setup...**

Optionally, you may change the name for the connection. This database name is used in the print request on line 321 in the ZSEAGULL_CL_API_CALL class.
