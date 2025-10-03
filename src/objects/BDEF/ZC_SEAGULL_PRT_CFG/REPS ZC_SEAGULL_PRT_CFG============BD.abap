projection implementation in class ZBP_C_SEAGULL_PRT_CFG unique;
strict ( 2 );
extensible;
use draft;
use side effects;
define behavior for ZC_SEAGULL_PRT_CFG alias ZcSeagullPrtCfg
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