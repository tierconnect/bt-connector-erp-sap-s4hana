*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lzcl_materialdoc_event_consump DEFINITION INHERITING FROM cl_abap_behavior_event_handler.

  PRIVATE SECTION.
    METHODS consume_created FOR ENTITY EVENT created FOR materialdocument~created.

ENDCLASS.

CLASS lzcl_materialdoc_event_consump IMPLEMENTATION.

  METHOD consume_created.


    READ ENTITIES OF i_materialdocumenttp
       ENTITY materialdocument
       FIELDS ( materialdocument materialdocumentyear )
       WITH CORRESPONDING #( created )
       RESULT DATA(lt_materialdocs).

    IF lt_materialdocs IS NOT INITIAL.
      SELECT *
             FROM i_materialdocumentheader_2 AS header
             JOIN i_materialdocumentheader_2 \_materialdocumentitem AS item
             ON header~materialdocument = item~materialdocument
             AND header~materialdocumentyear = item~materialdocumentyear
             WHERE header~materialdocument = @( lt_materialdocs[ 1 ]-materialdocument )
             AND header~materialdocumentyear = @( lt_materialdocs[ 1 ]-materialdocumentyear )
               INTO @DATA(ls_matdoc)
               UP TO 1 ROWS.
      ENDSELECT.
      IF sy-subrc EQ 0.

        SELECT *
        FROM zc_seagull_prt_cfg
        WHERE plant = @( ls_matdoc-item-plant )
        AND sloc = @( ls_matdoc-item-storagelocation )
        AND bwart = @( ls_matdoc-item-goodsmovementtype )
        AND doctype = @( ls_matdoc-header-accountingdocumenttype )
        INTO @DATA(ls_doc_prnt_config)
        UP TO 1 ROWS.
        ENDSELECT.
        IF sy-subrc EQ 0.

          DATA(lo_ref) = NEW zseagull_cl_api_call(  ).

          DATA(ls_print_info) = VALUE zseagull_cl_api_call=>ty_print_info(  printername = ls_doc_prnt_config-printername
                                                                              nooflabels = ls_doc_prnt_config-nooflabels
                                                                              labelformat = ls_doc_prnt_config-labelformat
                                                                              mblnr = lt_materialdocs[ 1 ]-materialdocument
                                                                              mjahr = lt_materialdocs[ 1 ]-materialdocumentyear ).

          lo_ref->post_print_info( EXPORTING
                                      is_print_info = ls_print_info
                                   IMPORTING
                                      ev_code = DATA(lv_code)
                                      ev_reason = DATA(lv_reason) ).

          IF  lv_code IS NOT INITIAL AND lv_reason IS NOT INITIAL.

            GET TIME STAMP FIELD DATA(lv_tstmp).

            DATA(lt_matdoc_prnt) = VALUE zseagull_cl_api_call=>tt_matdoc_prnt_tab( ( client = sy-mandt
                                                                                       mblnr = ls_print_info-mblnr
                                                                                       mjahr = ls_print_info-mjahr
                                                                                       no_of_labels = ls_print_info-nooflabels
                                                                                       label_format = ls_print_info-labelformat
                                                                                       printer_name = ls_print_info-printername
                                                                                       print_mode = 'During Creation'
                                                                                       print_response_code = lv_code
                                                                                       print_response_msg = lv_reason
                                                                                       created_by = sy-uname
                                                                                       created_at = lv_tstmp
                                                                                       last_changed_by = sy-uname
                                                                                       last_changed_at = lv_tstmp
                                                                                       local_last_changed_at = lv_tstmp ) ).

            lo_ref->upd_matdoc_prnt_tab( CHANGING ct_matdoc_prnt_tab = lt_matdoc_prnt ).

          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
