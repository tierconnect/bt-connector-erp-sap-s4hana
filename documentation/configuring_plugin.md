## Configuring the Plugin

>**Note:** The plugin requires an application registration in BarTender Cloud for successful authentication. See [Registering the Application](/documentation/registering_application.md)

## Procedure

1. In the SAP Fiori launchpad of your SAP S/4HANA Cloud Public Edition development system, search for and open the app called Seagull Connectivity - Bartender Label Print.

   >It is recommended to create a dedicated user account in BarTender Cloud for application connectivity.

2. Click the **Go** button to search for any existing records. If there are no existing records, click **Create** to create a new record.

   >**Note**: The plugin is written to use the first record from this table for connection information. There should only be one record at any time.

3. Enter the following values in the new record dialog and click **Continue**:

   - **Grant Type**: password
   - **Tenant**: Your BarTender Cloud organization name (e.g., `havensightconsulting`). This is MANDATORY.
   - **Region**: Your BarTender Cloud datacenter ID (e.g., `am1`). Defaults to `am1` if left empty.
   - **Host**: Your BarTender Cloud host domain (e.g., `bartendercloud.com`). Defaults to `bartendercloud.com` if left empty.
   - **Audience**: https://BarTenderCloudServiceApi

4. In the edit record screen, enter the following values, then click **Save**:

   - **Client ID**: Your Application ID from the application registration in BarTender Cloud
   - **Client Secret**: Your Application Secret from the application registration in BarTender Cloud
   - **Username**: Your BarTender Cloud username
   - **Password**: Your BarTender Cloud password
   >These values can be changed at any time by editing the record.

The BarTender Cloud API endpoints are now dynamically constructed from the Tenant, Region, and Host field values you provide in the configuration form. The plugin will automatically generate the correct URLs based on your BarTender Cloud tenant configuration.

## Determining Your BarTender Cloud Configuration Values

To configure the plugin, you will need your BarTender Cloud tenant information:

- **Organization Name**: Your BarTender Cloud organization name
- **Data Center ID**: Your BarTender Cloud datacenter location
- **Host**: Typically `bartendercloud.com` (unless using a custom domain)

You can find these values from the URL in BarTender Cloud, which follows this pattern:<br>
https://\<organizationName\>.\<dataCenterId\>.\<host\>/

### Example Configuration
If your BarTender Cloud URL is: `https://havensightconsulting.am1.bartendercloud.com/`

Then configure the plugin as follows:
- **Tenant**: `havensightconsulting`
- **Region**: `am1`
- **Host**: `bartendercloud.com`

The plugin will automatically construct the OAuth2 token endpoint and API endpoints from these values.
