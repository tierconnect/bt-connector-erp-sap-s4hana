managed implementation in class ZBP_R_SEAGULL_DOC_PRT unique;
strict ( 2 );
with draft;
extensible;
define behavior for ZR_SEAGULL_DOC_PRT alias ZrSeagullDocPrt
persistent table ZSEAGULL_DOC_PRT
extensible
draft table ZSGULL_DOC_PRT_D
etag master LocalLastChangedAt
lock master total etag LastChangedAt
authorization master( global )
{

  field ( readonly : update )
   OrderUuid,
   LastChangedBy,
   LastChangedAt,
   LocalLastChangedAt;

  field ( numbering : managed )
   OrderUUID;

  field ( features : instance )
   CreatedBy,
   CreatedAt,
   PrintResponseCode,
   PrintResponseMsg,
   PrintMode;

  action( features : instance ) printreprint result [1] $self;

  create;
  update( precheck );
  delete( precheck );

  validation ValidateInputMatdoc on save { create; field Mblnr; field Mjahr; }
  validation ValidateInputlabelformat on save { create; field LabelFormat; field NoOfLabels; }
  validation ValidateInputprinter on save { create; field PrinterName; }

  draft action Activate optimized;
  draft action Discard;
  draft action Edit;
  draft action Resume;
  draft determine action Prepare { validation ( always ) ValidateInputMatdoc;
                                   validation ( always ) ValidateInputlabelformat;
                                   validation ( always ) ValidateInputprinter; }

  mapping for ZSEAGULL_DOC_PRT corresponding extensible
  {
    OrderUUID = order_uuid;
    Mblnr = mblnr;
    Mjahr = mjahr;
    NoOfLabels = no_of_labels;
    LabelFormat = label_format;
    PrinterName = printer_name;
    PrintMode = print_mode;
    CreatedBy = created_by;
    CreatedAt = created_at;
    PrintResponseCode = print_response_code;
    PrintResponseMsg = print_response_msg;
    LastChangedBy = last_changed_by;
    LastChangedAt = last_changed_at;
    LocalLastChangedAt = local_last_changed_at;
  }

}