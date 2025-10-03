CLASS LHC_ZR_SEAGULL_DOC_PRT DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrSeagullDocPrt
        RESULT result,

        get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR ZrSeagullDocPrt RESULT result,

      printreprint FOR MODIFY
        IMPORTING keys FOR ACTION ZrSeagullDocPrt~printreprint RESULT result,

      validateinputmatdoc FOR VALIDATE ON SAVE
        IMPORTING keys FOR ZrSeagullDocPrt~validateinputmatdoc,

      validateinputlabelformat FOR VALIDATE ON SAVE
        IMPORTING keys FOR ZrSeagullDocPrt~validateinputlabelformat,

      validateinputprinter FOR VALIDATE ON SAVE
        IMPORTING keys FOR ZrSeagullDocPrt~validateinputprinter,

      precheck_update FOR PRECHECK
        IMPORTING entities FOR UPDATE ZrSeagullDocPrt,

      precheck_delete FOR PRECHECK
        IMPORTING keys FOR DELETE ZrSeagullDocPrt.
ENDCLASS.

CLASS LHC_ZR_SEAGULL_DOC_PRT IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

   METHOD printreprint.

    READ ENTITIES OF zr_seagull_doc_prt IN LOCAL MODE
    ENTITY ZrSeagullDocPrt
    ALL FIELDS WITH VALUE #( FOR key IN keys ( orderuuid = key-orderuuid ) )
    RESULT DATA(lt_print_info).

    DATA(lo_ref) = NEW zseagull_cl_api_call(  ).

    LOOP AT lt_print_info ASSIGNING FIELD-SYMBOL(<fs_print_info>).

      IF <fs_print_info>-printresponsecode = '200' OR <fs_print_info>-printresponsecode = '202'.
        APPEND VALUE #( %tky = <fs_print_info>-%tky ) TO failed-zrseagulldocprt.
        APPEND VALUE #( %tky          = <fs_print_info>-%tky
                        %state_area   = 'VALIDATE_PRINT'
                        %msg          = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Print Request is already processed.' )
                        %element-mblnr = if_abap_behv=>mk-on
                     ) TO reported-zrseagulldocprt.
        RETURN.
      ENDIF.

      lo_ref->post_print_info( EXPORTING
                                  is_print_info = CORRESPONDING #( <fs_print_info> )
                               IMPORTING
                                  ev_code = DATA(lv_code)
                                  ev_reason = DATA(lv_reason) ).

      IF  lv_code IS NOT INITIAL AND lv_reason IS NOT INITIAL.

        MODIFY ENTITIES OF zr_seagull_doc_prt IN LOCAL MODE
        ENTITY ZrSeagullDocPrt UPDATE
        SET FIELDS WITH VALUE #( (
                         orderuuid = <fs_print_info>-orderuuid
                         printmode = 'By Print App'
                         printresponsecode = lv_code
                         printresponsemsg = lv_reason
                         %control-printmode = if_abap_behv=>mk-on
                         %control-printresponsecode = if_abap_behv=>mk-on
                         %control-printresponsemsg = if_abap_behv=>mk-on ) )
        FAILED failed
        REPORTED reported.

        READ ENTITIES OF zr_seagull_doc_prt IN LOCAL MODE
        ENTITY ZrSeagullDocPrt
        FROM VALUE #( FOR key IN keys ( orderuuid = key-orderuuid ) )
        RESULT DATA(lt_matdoc_print).

        result = VALUE #( FOR lw_matdoc_print IN lt_matdoc_print (
                                            orderuuid = lw_matdoc_print-orderuuid
                                            %param = lw_matdoc_print ) ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    MOVE-CORRESPONDING keys TO result.
    LOOP AT result ASSIGNING FIELD-SYMBOL(<fs_result>).


      <fs_result>-%field-createdat = if_abap_behv=>fc-f-read_only.
      <fs_result>-%field-createdby = if_abap_behv=>fc-f-read_only.
      <fs_result>-%field-printmode = if_abap_behv=>fc-f-read_only.
      <fs_result>-%field-printresponsecode = if_abap_behv=>fc-f-read_only.
      <fs_result>-%field-printresponsemsg = if_abap_behv=>fc-f-read_only.

      <fs_result>-%action-printreprint = COND #( WHEN <fs_result>-%is_draft = if_abap_behv=>mk-on
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled ).
    ENDLOOP.

  ENDMETHOD.

  METHOD validateinputmatdoc.

    "read relevant Material Document instance data
    READ ENTITIES OF zr_seagull_doc_prt IN LOCAL MODE
    ENTITY ZrSeagullDocPrt
    FIELDS ( mblnr mjahr )
    WITH CORRESPONDING #( keys )
    RESULT DATA(materialdocs).

if materialdocs IS not INITIAL.
    SELECT  materialdocument,
            materialdocumentyear
      FROM zseagull_i_matdocs
      FOR ALL ENTRIES IN @materialdocs
      WHERE materialdocument = @materialdocs-mblnr
      AND materialdocumentyear = @materialdocs-mjahr
      INTO TABLE @DATA(lt_matdocs_tab).

    IF sy-subrc NE 0.
      CLEAR lt_matdocs_tab.
    ENDIF.
endif.

    "raise message if Material document No. is empty
    LOOP AT materialdocs INTO DATA(ls_materialdocs).
      APPEND VALUE #(  %tky           = ls_materialdocs-%tky
                      %state_area    = 'VALIDATE_MATDOC'
                    ) TO reported-zrseagulldocprt.

      IF ls_materialdocs-mblnr IS INITIAL OR ls_materialdocs-mblnr = ' '.
        APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagulldocprt.
        APPEND VALUE #( %tky          = ls_materialdocs-%tky
                        %state_area   = 'VALIDATE_MATDOC'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Material Document No. can not be empty' )
                        %element-mblnr = if_abap_behv=>mk-on
                      ) TO reported-zrseagulldocprt.
      ELSE.

        IF ls_materialdocs-mjahr IS INITIAL.
          APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagulldocprt.
          APPEND VALUE #( %tky          = ls_materialdocs-%tky
                          %state_area   = 'VALIDATE_MATDOC'
                          %msg          = new_message_with_text(
                                  severity = if_abap_behv_message=>severity-error
                                  text     = 'Material Document Year can not be empty' )
                          %element-mjahr = if_abap_behv=>mk-on
                        ) TO reported-zrseagulldocprt.

        ELSE.
          IF NOT line_exists( lt_matdocs_tab[ materialdocument = ls_materialdocs-mblnr
                                              materialdocumentyear = ls_materialdocs-mjahr ] ).
            APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagulldocprt.
            APPEND VALUE #( %tky          = ls_materialdocs-%tky
                            %state_area   = 'VALIDATE_MATDOC'
                            %msg          = new_message_with_text(
                                    severity = if_abap_behv_message=>severity-error
                                    text     = |{ 'Material Document No. does not exist in Year' } { ls_materialdocs-mjahr }| )
                            %element-mblnr = if_abap_behv=>mk-on
                          ) TO reported-zrseagulldocprt.

          ENDIF.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateinputlabelformat.

    READ ENTITIES OF zr_seagull_doc_prt IN LOCAL MODE
     ENTITY zrseagulldocprt
     FIELDS ( labelformat nooflabels )
     WITH CORRESPONDING #( keys )
     RESULT DATA(materialdocs).

    DATA(lo_ref) = NEW zseagull_cl_api_call(  ).

    lo_ref->get_label_format( IMPORTING et_label_format = DATA(lt_labelformat_dtl) ).

    "raise message if Label Format is empty
    LOOP AT materialdocs INTO DATA(ls_materialdocs).
      APPEND VALUE #(  %tky           = ls_materialdocs-%tky
                      %state_area    = 'VALIDATE_LABELFORMAT'
                    ) TO reported-zrseagulldocprt.

      IF ls_materialdocs-labelformat IS INITIAL OR ls_materialdocs-labelformat = ' '.
        APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagulldocprt.
        APPEND VALUE #( %tky          = ls_materialdocs-%tky
                        %state_area   = 'VALIDATE_LABELFORMAT'
                        %msg          = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'Label Format can not be empty' )
                        %element-labelformat = if_abap_behv=>mk-on
                      ) TO reported-zrseagulldocprt.
      ELSE.

        IF NOT line_exists( lt_labelformat_dtl[ labelformat = ls_materialdocs-labelformat ] ).
          APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagulldocprt.
          APPEND VALUE #( %tky          = ls_materialdocs-%tky
                          %state_area   = 'VALIDATE_LABELFORMAT'
                          %msg          = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Label Format is not maintained in Bartender System' )
                          %element-labelformat = if_abap_behv=>mk-on
                        ) TO reported-zrseagulldocprt.

        ENDIF.
      ENDIF.

      IF ls_materialdocs-nooflabels IS INITIAL OR ls_materialdocs-nooflabels = ' '.
        APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagulldocprt.
        APPEND VALUE #( %tky          = ls_materialdocs-%tky
                        %state_area   = 'VALIDATE_LABELFORMAT'
                        %msg          = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'No. of Copies can not be empty' )
                        %element-nooflabels = if_abap_behv=>mk-on
                      ) TO reported-zrseagulldocprt.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateinputprinter.

    READ ENTITIES OF zr_seagull_doc_prt IN LOCAL MODE
     ENTITY zrseagulldocprt
     FIELDS ( printername )
     WITH CORRESPONDING #( keys )
     RESULT DATA(materialdocs).

    DATA(lo_ref) = NEW zseagull_cl_api_call(  ).

    lo_ref->get_printer_dtl( IMPORTING et_printer_dtl = DATA(lt_printer_dtl) ).

    "raise message if Label Format is empty
    LOOP AT materialdocs INTO DATA(ls_materialdocs).
      APPEND VALUE #(  %tky           = ls_materialdocs-%tky
                      %state_area    = 'VALIDATE_PRINTERNAME'
                    ) TO reported-zrseagulldocprt.

      IF ls_materialdocs-printername IS INITIAL OR ls_materialdocs-printername = ' '.
        APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagulldocprt.
        APPEND VALUE #( %tky          = ls_materialdocs-%tky
                        %state_area   = 'VALIDATE_PRINTERNAME'
                        %msg          = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Printer Name can not be empty' )
                        %element-printername = if_abap_behv=>mk-on
                      ) TO reported-zrseagulldocprt.
      ELSE.

        IF NOT line_exists( lt_printer_dtl[ printerid = ls_materialdocs-printername ] ).
          APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagulldocprt.
          APPEND VALUE #( %tky          = ls_materialdocs-%tky
                          %state_area   = 'VALIDATE_PRINTERNAME'
                          %msg          = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text     = 'Printer is not maintained in Bartender System' )
                          %element-printername = if_abap_behv=>mk-on
                        ) TO reported-zrseagulldocprt.

        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_update.

    READ ENTITIES OF zr_seagull_doc_prt IN LOCAL MODE
          ENTITY zrseagulldocprt
          FIELDS ( printresponsecode )
          WITH CORRESPONDING #( entities )
          RESULT DATA(materialdocs).

    LOOP AT materialdocs INTO DATA(ls_materialdocs).
      IF ls_materialdocs-printresponsecode = '200' OR ls_materialdocs-printresponsecode = '202'.

        APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagulldocprt.
        APPEND VALUE #( %tky          = ls_materialdocs-%tky
                        "%state_area   = 'VALIDATE_PRINTERNAME'
                        %msg          = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Successful printed document can not be changed' )
                        %element-printername = if_abap_behv=>mk-on
                      ) TO reported-zrseagulldocprt.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_delete.

    READ ENTITIES OF zr_seagull_doc_prt IN LOCAL MODE
      ENTITY zrseagulldocprt
      FIELDS ( printresponsecode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(materialdocs).

    LOOP AT materialdocs INTO DATA(ls_materialdocs).
      IF ls_materialdocs-printresponsecode = '200' OR ls_materialdocs-printresponsecode = '202'.

        APPEND VALUE #( %tky = ls_materialdocs-%tky ) TO failed-zrseagulldocprt.
        APPEND VALUE #( %tky          = ls_materialdocs-%tky
                        "%state_area   = 'VALIDATE_PRINTERNAME'
                        %msg          = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = 'Successful printed document can not be deleted' )
                       " %element-printername = if_abap_behv=>mk-on
                      ) TO reported-zrseagulldocprt.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
