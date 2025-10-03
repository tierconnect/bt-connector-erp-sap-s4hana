CLASS lhc_zr_seagull_prt_cfg DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zrseagullprtcfg
        RESULT result,

      validateinputlabelformat FOR VALIDATE ON SAVE
        IMPORTING keys FOR zrseagullprtcfg~validateinputlabelformat,

      validateinputprinter FOR VALIDATE ON SAVE
        IMPORTING keys FOR zrseagullprtcfg~validateinputprinter.
ENDCLASS.

CLASS lhc_zr_seagull_prt_cfg IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validateinputlabelformat.

    READ ENTITIES OF zr_seagull_prt_cfg IN LOCAL MODE
      ENTITY zrseagullprtcfg
      FIELDS ( labelformat nooflabels )
      WITH CORRESPONDING #( keys )
      RESULT DATA(materialdocs).

    DATA(lo_ref) = NEW zseagull_cl_api_call(  ).

    lo_ref->get_label_format( IMPORTING et_label_format = DATA(lt_labelformat_dtl) ).

    "raise message if Label Format is empty
    LOOP AT materialdocs INTO DATA(ls_materialdocs).
      APPEND VALUE #(  %tky           = ls_materialdocs-%tky
                      %state_area    = 'VALIDATE_LABELFORMAT'
                    ) TO reported-zrseagullprtcfg.

      IF ls_materialdocs-labelformat IS INITIAL OR ls_materialdocs-labelformat = ' '.
        APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagullprtcfg.
        APPEND VALUE #( %tky          = ls_materialdocs-%tky
                        %state_area   = 'VALIDATE_LABELFORMAT'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Label Format can not be empty' )
                        %element-labelformat = if_abap_behv=>mk-on
                      ) TO reported-zrseagullprtcfg.
      ELSE.

        IF NOT line_exists( lt_labelformat_dtl[ labelformat = ls_materialdocs-labelformat ] ).
          APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagullprtcfg.
          APPEND VALUE #( %tky          = ls_materialdocs-%tky
                          %state_area   = 'VALIDATE_LABELFORMAT'
                          %msg          = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Label Format is not maintained in Bartender System' )
                          %element-labelformat = if_abap_behv=>mk-on
                        ) TO reported-zrseagullprtcfg.

        ENDIF.
      ENDIF.

      IF ls_materialdocs-nooflabels IS INITIAL OR ls_materialdocs-nooflabels = ' '.
        APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagullprtcfg.
        APPEND VALUE #( %tky          = ls_materialdocs-%tky
                        %state_area   = 'VALIDATE_LABELFORMAT'
                        %msg          = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'No. of Copies can not be empty' )
                        %element-nooflabels = if_abap_behv=>mk-on
                      ) TO reported-zrseagullprtcfg.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateinputprinter.

    READ ENTITIES OF zr_seagull_prt_cfg IN LOCAL MODE
      ENTITY zrseagullprtcfg
      FIELDS ( printername )
      WITH CORRESPONDING #( keys )
      RESULT DATA(materialdocs).

    DATA(lo_ref) = NEW zseagull_cl_api_call(  ).

    lo_ref->get_printer_dtl( IMPORTING et_printer_dtl = DATA(lt_printer_dtl) ).

    "raise message if Label Format is empty
    LOOP AT materialdocs INTO DATA(ls_materialdocs).
      APPEND VALUE #(  %tky           = ls_materialdocs-%tky
                      %state_area    = 'VALIDATE_PRINTERNAME'
                    ) TO reported-zrseagullprtcfg.

      IF ls_materialdocs-printername IS INITIAL OR ls_materialdocs-printername = ' '.
        APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagullprtcfg.
        APPEND VALUE #( %tky          = ls_materialdocs-%tky
                        %state_area   = 'VALIDATE_PRINTERNAME'
                        %msg          = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Printer Name can not be empty' )
                        %element-printername = if_abap_behv=>mk-on
                      ) TO reported-zrseagullprtcfg.
      ELSE.

        IF NOT line_exists( lt_printer_dtl[ printerid = ls_materialdocs-printername ] ).
          APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagullprtcfg.
          APPEND VALUE #( %tky          = ls_materialdocs-%tky
                          %state_area   = 'VALIDATE_PRINTERNAME'
                          %msg          = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Printer is not maintained in Bartender System' )
                          %element-printername = if_abap_behv=>mk-on
                        ) TO reported-zrseagullprtcfg.

        ENDIF.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
