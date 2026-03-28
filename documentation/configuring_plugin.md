## Configuring the Plugin

>**Note:** The plugin requires an application registration in BarTender Cloud for successful authentication. See [Registering the Application](/documentation/registering_application.md)

## Procedure

1. In the SAP Fiori launchpad of your SAP S/4HANA Cloud Public Edition development system, search for and open the app called Seagull Connectivity - Bartender Label Print.

   >It is recommended to create a dedicated user account in BarTender Cloud for application connectivity.

2. Click the **Go** button to search for any existing records. If there are no existing records, click **Create** to create a new record.

   >**Note**: The plugin is written to use the first record from this table for connection information. There should only be one record at any time.

3. Enter the following values in the new record dialog and click **Continue**:

   - **Grant Type**: password
   - **Destination**: The identity provider endpoint for your BarTender Cloud tenant. See section below for determining the endpoint URL.
   - **Audience**: https://BarTenderCloudServiceApi

4. In the edit record screen, enter the following values, then click **Save**:

   - **Client ID**: Your Application ID from the application registration in BarTender Cloud
   - **Client Secret**: Your Application Secret from the application registration in BarTender Cloud
   - **Username**: Your BarTender Cloud username
   - **Password**: Your BarTender Cloud password
   >These values can be changed at any time by editing the record.

The BarTender Cloud tenant URL must also be changed in the ZSEAGULL_CL_API_CALL class on lines 102, 162, and 332. For all 3 lines, replace the host portion of the URL with the host of your BarTender cloud tenant. This will include your Organization Name and DataCenter ID.

## Determining the Destination URL
To build the URL for the identity provider, you will need your Organization Name and the Data Center ID for your BarTender Cloud tenant.

You can find these from the URL in BarTender Cloud. The URL will follow this format:<br>
https://\<organizationName\>.\<dataCenterId\>.bartendercloud.com/

Fill in the following URL with your Organization Name and Data Center ID values. This is the Destination URL.<br>
https://auth.\<dataCenterId\>.bartendercloud.com/connect/token?OrganizationDnsName=\<organizationName\>
