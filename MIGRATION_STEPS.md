# Migration Steps: Hardcoded URLs to Configuration-Based

This document outlines the changes made to remove hardcoded BarTender Cloud URLs and make them configurable through the SAP Fiori form.

## Summary of Changes

### ABAP Code Changes (✅ Completed)
- **File**: `src/objects/CLAS/ZSEAGULL_CL_API_CALL/zseagull_cl_api_call.clas.abap`
- **Changes Made**:
  1. Added new method `get_api_base_url()`: Constructs the base API URL from configuration (tenant, region, host)
  2. Added new method `get_bearer_token_url()`: Constructs the OAuth2 token endpoint URL from configuration
  3. Updated `get_label_format()` method to use `get_api_base_url()` instead of hardcoded URL
  4. Updated `get_printer_dtl()` method to use `get_api_base_url()` instead of hardcoded URL
  5. Updated `post_print_info()` method to use `get_api_base_url()` instead of hardcoded URL
  6. Updated `get_bearer_token()` method to use `get_bearer_token_url()` instead of hardcoded destination URL

### Configuration Documentation Changes (✅ Completed)
- **File**: `documentation/configuring_plugin.md`
- **Changes Made**:
  1. Removed references to manually updating hardcoded URLs in the ABAP code
  2. Updated configuration form instructions to include three new fields:
     - **Tenant** (mandatory): Organization name (e.g., `havensightconsulting`)
     - **Region** (optional, default: `am1`): Datacenter ID (e.g., `am1`)
     - **Host** (optional, default: `bartendercloud.com`): Base host domain
  3. Added "Determining Your BarTender Cloud Configuration Values" section with examples
  4. Removed the old "Determining the Destination URL" section

### Database Schema Changes (⚠️ Still Required)

To complete this migration, the following database changes are required:

#### Add fields to ZSEAGULL_CRED table:

```sql
ALTER TABLE ZSEAGULL_CRED ADD (
  TENANT VARCHAR(50) NOT NULL,     -- Organization name (mandatory)
  REGION VARCHAR(20) DEFAULT 'am1',  -- Datacenter ID (optional, default 'am1')
  HOST VARCHAR(50) DEFAULT 'bartendercloud.com'  -- Base host (optional, default)
);
```

#### Update CDS Views:

**File**: `src/objects/DDLS/ZR_SEAGULL_CRED/DDLS ZR_SEAGULL_CRED.asx.json`

Replace the `source` with:
```java
define root view entity ZR_SEAGULL_CRED
  as select from zseagull_cred
{
  key grant_type as GrantType,
  tenant as Tenant,
  region as Region,
  host as Host,
  audience as Audience,
  client_id as ClientID,
  client_secret as ClientSecret,
  username as Username,
  password as Password,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
}
```

**File**: `src/objects/DDLS/ZC_SEAGULL_CRED/DDLS ZC_SEAGULL_CRED.asx.json`

Update the projection to include the new fields:
```java
define root view entity ZC_SEAGULL_CRED
  provider contract transactional_query
  as projection on ZR_SEAGULL_CRED
{
  key GrantType,
  Tenant,
  Region,
  Host,
  Audience,
  ClientID,
  ClientSecret,
  Username,
  Password,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
}
```

#### Update UI Annotations:

**File**: `src/objects/DDLX/ZC_SEAGULL_CRED/DDLX ZC_SEAGULL_CRED.asx.json`

Add field annotations for the UI form (positioning, labels, etc.):
```java
@UI.fieldGroup: [{ position: 30, label: 'Tenant' }]
Tenant;

@UI.fieldGroup: [{ position: 40, label: 'Region' }]
Region;

@UI.fieldGroup: [{ position: 50, label: 'Host' }]
Host;
```

## Migration Path

### For Existing Systems:

1. Back up your current configuration record in `ZSEAGULL_CRED`
2. Deploy the new ABAP code changes
3. Update the database table schema (add the new fields)
4. Activate the updated CDS views
5. Publish the service bindings for the updated UI
6. Update the existing configuration record:
   - Extract organization name and datacenter from the old destination/URL
   - Populate Tenant, Region, and Host fields
   - (Optional) Keep Destination field for backward compatibility
7. Test the connectivity with the new configuration

### For New Installations:

1. Deploy all changes together
2. The form will now present the three new fields (Tenant, Region, Host) instead of Destination
3. Configure as per the updated documentation

## Benefits of This Change

✅ **No Manual Code Updates**: When changing tenants or datacenters, only update the form - no code changes needed  
✅ **Clearer Configuration**: Three explicit fields instead of one complex URL  
✅ **Default Values**: Region and Host have sensible defaults  
✅ **Reusable URL Construction**: Two utility methods can construct any required URL format  
✅ **Multi-Tenant Support**: Easier to support multiple BarTender Cloud tenants in the future  

## Rollback Instructions

If you need to revert these changes:

1. Restore the previous version of `zseagull_cl_api_call.clas.abap`
2. Restore the previous CDS view definitions
3. Remove the Tenant, Region, Host fields from the table (or keep them unused)
4. Restore the previous UI annotations
5. Reactivate the CDS views and publish service bindings
