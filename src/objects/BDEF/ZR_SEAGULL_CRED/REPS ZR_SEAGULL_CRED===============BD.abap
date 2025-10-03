managed implementation in class ZBP_R_SEAGULL_CRED unique;
strict ( 2 );
with draft;
extensible;
define behavior for ZR_SEAGULL_CRED alias ZrSeagullCred
persistent table ZSEAGULL_CRED
extensible
draft table ZSEAGULL_CRED_D
etag master LocalLastChangedAt
lock master total etag LastChangedAt
authorization master( global )
{
  field ( mandatory : create )
   Destination,
   GrantType,
   Audience;

  field ( readonly )
   CreatedBy,
   CreatedAt,
   LastChangedBy,
   LastChangedAt,
   LocalLastChangedAt;

  field ( readonly : update )
   Destination,
   GrantType,
   Audience;


  create;
  update;
  delete;

  draft action Activate optimized;
  draft action Discard;
  draft action Edit;
  draft action Resume;
  draft determine action Prepare;

  mapping for ZSEAGULL_CRED corresponding extensible
  {
    Destination = destination;
    GrantType = grant_type;
    Audience = audience;
    ClientID = client_id;
    ClientSecret = client_secret;
    Username = username;
    Password = password;
    CreatedBy = created_by;
    CreatedAt = created_at;
    LastChangedBy = last_changed_by;
    LastChangedAt = last_changed_at;
    LocalLastChangedAt = local_last_changed_at;
  }

}