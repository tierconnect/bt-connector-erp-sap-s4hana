managed implementation in class ZBP_R_SEAGULL_PRT_CFG unique;
strict ( 2 );
with draft;
extensible;
define behavior for ZR_SEAGULL_PRT_CFG alias ZrSeagullPrtCfg
persistent table ZSEAGULL_PRT_CFG
extensible
draft table ZSGULL_PRT_CFG_D
etag master LocalLastChangedAt
lock master total etag LastChangedAt
authorization master( global )
{
  field ( mandatory : create )
   Plant,
   Sloc,
   Bwart,
   Doctype;

  field ( readonly )
   CreatedBy,
   CreatedAt,
   LastChangedBy,
   LastChangedAt,
   LocalLastChangedAt;

  field ( readonly : update )
   Plant,
   Sloc,
   Bwart,
   Doctype;


  create;
  update;
  delete;

  validation ValidateInputlabelformat on save { create; field LabelFormat; field NoOfLabels; }
  validation ValidateInputprinter on save { create; field PrinterName; }

  draft action Activate optimized;
  draft action Discard;
  draft action Edit;
  draft action Resume;
 draft determine action Prepare {  validation ( always ) ValidateInputlabelformat;
                                   validation ( always ) ValidateInputprinter; }

  mapping for ZSEAGULL_PRT_CFG corresponding extensible
  {
    Plant = plant;
    Sloc = sloc;
    Bwart = bwart;
    Doctype = doctype;
    LabelFormat = label_format;
    NoOfLabels = no_of_labels;
    PrinterName = printer_name;
    CreatedBy = created_by;
    CreatedAt = created_at;
    LastChangedBy = last_changed_by;
    LastChangedAt = last_changed_at;
    LocalLastChangedAt = local_last_changed_at;
  }

}