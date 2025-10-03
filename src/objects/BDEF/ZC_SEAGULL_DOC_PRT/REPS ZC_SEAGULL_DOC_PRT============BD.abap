projection implementation in class ZBP_C_SEAGULL_DOC_PRT unique;
strict ( 2 );
extensible;
use draft;
use side effects;
define behavior for ZC_SEAGULL_DOC_PRT alias ZcSeagullDocPrt
extensible
use etag
{
  use create;
  use update;
  use delete;

  use action printreprint;
  use action Edit;
  use action Activate;
  use action Discard;
  use action Resume;
  use action Prepare;

}