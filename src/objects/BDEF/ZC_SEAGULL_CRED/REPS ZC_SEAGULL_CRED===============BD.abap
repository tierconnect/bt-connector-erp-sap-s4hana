projection implementation in class ZBP_C_SEAGULL_CRED unique;
strict ( 2 );
extensible;
use draft;
use side effects;
define behavior for ZC_SEAGULL_CRED alias ZcSeagullCred
extensible
use etag
{
  use create;
  use update;
  use delete;

  use action Edit;
  use action Activate;
  use action Discard;
  use action Resume;
  use action Prepare;

}