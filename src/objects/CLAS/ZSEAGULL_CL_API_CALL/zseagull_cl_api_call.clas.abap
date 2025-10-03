CLASS zseagull_cl_api_call DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_printer_dtl,
             printerid(100) TYPE c,
           END OF ty_printer_dtl,

           BEGIN OF ty_labelformat_dtl,
             labelformat(100) TYPE c,
           END OF ty_labelformat_dtl,

           BEGIN OF ty_print_info,
             printername(100) TYPE c,
             nooflabels(4)    TYPE c,
             labelformat(100) TYPE c,
             mblnr(10)        TYPE c,
             mjahr(4)         TYPE c,
           END OF ty_print_info,

           BEGIN OF ty_bearer_token,
             access_token TYPE string,
             token_type   TYPE string,
             expires_in   TYPE i,
             scope        TYPE string,
           END OF ty_bearer_token,

           tt_printer_dtl     TYPE STANDARD TABLE OF ty_printer_dtl,
           tt_labelformat_dtl TYPE STANDARD TABLE OF ty_labelformat_dtl,
           tt_matdoc_prnt_tab TYPE STANDARD TABLE OF zseagull_doc_prt WITH DEFAULT KEY.

    METHODS: get_bearer_token EXPORTING ev_bearer_token TYPE string,

      get_printer_dtl EXPORTING et_printer_dtl TYPE tt_printer_dtl,

      get_label_format EXPORTING et_label_format TYPE tt_labelformat_dtl,

      post_print_info IMPORTING is_print_info TYPE ty_print_info
                      EXPORTING ev_code       TYPE i
                                ev_reason     TYPE string,

      upd_matdoc_prnt_tab IMPORTING iv_commit          TYPE abap_boolean OPTIONAL
                          EXPORTING ev_upd_flag        TYPE abap_boolean
                          CHANGING  ct_matdoc_prnt_tab TYPE tt_matdoc_prnt_tab.

    DATA : out TYPE REF TO if_oo_adt_classrun_out.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zseagull_cl_api_call IMPLEMENTATION.


  METHOD get_label_format.

    TYPES: BEGIN OF ty_label_data,
             searchfileattributetype(1) TYPE c,
             filenamecontainsquery(4)   TYPE c,
             metadatakeysexistquery(1)  TYPE c,
             limit(2)                   TYPE c,
             skip(2)                    TYPE c,
           END OF ty_label_data,

           BEGIN OF ty_searchresult,
             uncpath(40) TYPE c,
             name(40)    TYPE c,
           END OF ty_searchresult,

           tt_searchresult TYPE STANDARD TABLE OF ty_searchresult WITH DEFAULT KEY,

           BEGIN OF ty_label_dtl,
             searchresultfilematches TYPE tt_searchresult,
           END OF ty_label_dtl.

    DATA: ls_label_dtl TYPE ty_label_dtl.


    DATA: lo_http_response TYPE REF TO if_web_http_response.

    get_bearer_token( IMPORTING ev_bearer_token = DATA(lv_string) ).
    TRY.


        DATA(lt_mappings) = VALUE /ui2/cl_json=>name_mappings( ( abap = 'searchfileattributetype' json = 'SearchFileAttributeType' )
                                                           ( abap = 'filenamecontainsquery' json = 'FileNameContainsQuery' )
                                                           ( abap = 'metadatakeysexistquery' json = 'MetadataKeysExistQuery' )
                                                           ( abap = 'limit' json = 'Limit' )
                                                           ( abap = 'skip' json = 'Skip' ) ).

        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( 'https://havensightconsulting.am1.bartendercloud.com/api/librarian/spaces/1/files/search/' ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).

        DATA(ls_label_data) = VALUE ty_label_data( searchfileattributetype = 1
                                                   filenamecontainsquery = '.btw'
                                                   metadatakeysexistquery = abap_false
                                                   limit = 0
                                                   skip = 0 ).

        DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_label_data
                                                 pretty_name = abap_true
                                                 format_output =  abap_true
                                                 name_mappings = lt_mappings ).

        lo_http_client->get_http_request(  )->set_authorization_bearer( i_bearer = lv_string ).

        lo_http_client->get_http_request(  )->set_header_fields( VALUE #(  ( name = if_web_http_header=>content_type value = if_web_http_header=>accept_application_json )
                                                                           ( name = if_web_http_header=>accept value = if_web_http_header=>accept_application_json ) ) ).

        lo_http_client->get_http_request(  )->set_text( lv_json ).

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).

        DATA(lv_response) = lo_response->get_text(  ).

        /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                             pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                   CHANGING data = ls_label_dtl ).


        et_label_format = VALUE #( FOR <fs_label_dtl> IN ls_label_dtl-searchresultfilematches ( labelformat = <fs_label_dtl>-uncpath && <fs_label_dtl>-name ) ).

        lo_http_client->close(  ).

      CATCH cx_http_dest_provider_error.
      return.
      catch cx_web_http_client_error.

        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD get_printer_dtl.



    get_bearer_token( IMPORTING ev_bearer_token = DATA(lv_string) ).
    TRY.
        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( 'https://havensightconsulting.am1.bartendercloud.com/api/printers/' ).
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).

        lo_http_client->get_http_request(  )->set_authorization_bearer( i_bearer = lv_string ).
        lo_http_client->get_http_request(  )->set_header_fields( VALUE #(  ( name = if_web_http_header=>content_type value = if_web_http_header=>accept_application_json )
                                                                           ( name = if_web_http_header=>accept value = if_web_http_header=>accept_application_json ) ) ).

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

        DATA(lv_response) = lo_response->get_text(  ).

        /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                             pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                   CHANGING data = et_printer_dtl ).

        lo_http_client->close(  ).

      CATCH cx_http_dest_provider_error.
            return.
      CATCH cx_web_http_client_error.

        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD post_print_info.

    TYPES: BEGIN OF ty_nameddatasources,
             trackingnumber TYPE char13,
             serialnumber   TYPE char13,
           END OF ty_nameddatasources,

           BEGIN OF ty_matdocdtl,
             header TYPE i_materialdocumentheader_2,
             items  TYPE STANDARD TABLE OF i_materialdocumentitem_2 WITH DEFAULT KEY,
           END OF ty_matdocdtl,

           BEGIN OF ty_database_overrides,
             datasourcevariablename TYPE string,
             name                   TYPE string,
             type                   TYPE string,
           END OF ty_database_overrides,

           BEGIN OF ty_printbtwaction,
             document           TYPE string,
             name               TYPE string,
             printer            TYPE string,
             copies(4)          TYPE c,
             saveafterprint     TYPE char05,
             promptfordatainput TYPE char05,
             returnprintsummary TYPE char05,
             returnprintdata    TYPE char05,
             queueandcontinue   TYPE char05,
             printjobtimeout(2) TYPE c,
             databaseoverrides  TYPE STANDARD TABLE OF ty_database_overrides WITH DEFAULT KEY,
           END OF ty_printbtwaction,

           BEGIN OF ty_setvariableaction,
             variablename  TYPE string,
             variablevalue TYPE string,
           END OF ty_setvariableaction,

           BEGIN OF ty_actions,
             setvariableaction TYPE ty_setvariableaction,
             printbtwaction    TYPE ty_printbtwaction,
           END OF ty_actions,

           BEGIN OF ty_actiongroup,
             actions TYPE STANDARD TABLE OF ty_actions WITH DEFAULT KEY,
           END OF ty_actiongroup,

           BEGIN OF ty_print_data,
             actiongroup TYPE ty_actiongroup,
           END OF ty_print_data,

           BEGIN OF ty_response_data,
             id        TYPE string,
             status    TYPE string,
             statusurl TYPE string,
             messages  TYPE string_table,
           END OF ty_response_data.

    DATA: ls_response_data TYPE ty_response_data.

    DATA: ls_matdocdtl TYPE ty_matdocdtl,
          lt_items     TYPE STANDARD TABLE OF i_materialdocumentitem_2.

    SELECT *
    FROM i_materialdocumentheader_2 AS header
    JOIN i_materialdocumentheader_2 \_materialdocumentitem AS item
    ON header~materialdocument = item~materialdocument
    AND header~materialdocumentyear = item~materialdocumentyear
    WHERE header~materialdocument = @is_print_info-mblnr
    AND header~materialdocumentyear = @is_print_info-mjahr
    INTO TABLE @DATA(lt_matdoc).

    IF sy-subrc EQ 0.
      LOOP AT lt_matdoc ASSIGNING FIELD-SYMBOL(<fs_matdoc>).
        IF sy-tabix = 1.
          ls_matdocdtl = VALUE #( header = <fs_matdoc>-header ).
        ENDIF.

        ls_matdocdtl-items = VALUE #( BASE ls_matdocdtl-items ( CORRESPONDING #( <fs_matdoc>-item ) ) ).
      ENDLOOP.
    ENDIF.

    DATA(lv_matdoc_json) = /ui2/cl_json=>serialize(
      data        = ls_matdocdtl
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      format_output =  abap_true ).

    get_bearer_token( IMPORTING ev_bearer_token = DATA(lv_string) ).

    DATA(lt_mappings) = VALUE /ui2/cl_json=>name_mappings( ( abap = 'actiongroup' json = 'ActionGroup' )
                                                       ( abap = 'actions' json = 'Actions' )
                                                       ( abap = 'setvariableaction' json = 'SetVariableAction' )
                                                       ( abap = 'variablename' json = 'VariableName' )
                                                       ( abap = 'variablevalue' json = 'VariableValue' )
                                                       ( abap = 'printbtwaction' json = 'PrintBTWAction' )
                                                       ( abap = 'document' json = 'Document' )
                                                       ( abap = 'name' json = 'Name' )
                                                       ( abap = 'printer' json = 'Printer' )
                                                       ( abap = 'copies' json = 'Copies' )
                                                       ( abap = 'saveafterprint' json = 'SaveAfterPrint' )
                                                       ( abap = 'promptfordatainput' json = 'PromptForDataInput' )
                                                       ( abap = 'returnprintsummary' json = 'ReturnPrintSummary' )
                                                       ( abap = 'returnprintdata' json = 'ReturnPrintData' )
                                                       ( abap = 'queueandcontinue' json = 'QueueAndContinue' )
                                                       ( abap = 'printjobtimeout' json = 'PrintJobTimeout' )
                                                       ( abap = 'databaseoverrides' json = 'DatabaseOverrides' )
                                                       ( abap = 'datasourcevariablename' json = 'DataSourceVariableName' )
                                                       ( abap = 'type' json = 'Type' ) ).

    DATA(ls_print_data) = VALUE ty_print_data( actiongroup = VALUE #( actions = VALUE #( ( setvariableaction = VALUE #( variablename = 'JSONData' variablevalue = lv_matdoc_json ) )
                                                                                         ( printbtwaction = VALUE #( document = is_print_info-labelformat
                                                                                                                     name = 'Print Document'
                                                                                                                     printer = 'printer:' && is_print_info-printername
                                                                                                                     copies = is_print_info-nooflabels
                                                                                                                     saveafterprint = 'false'
                                                                                                                     promptfordatainput = 'false'
                                                                                                                     returnprintsummary = 'true'
                                                                                                                     returnprintdata = 'true'
                                                                                                                     queueandcontinue = 'false'
                                                                                                                     printjobtimeout = '-1'
                                                                                                                     databaseoverrides = VALUE #( ( datasourcevariablename = 'JSONData'
                                                                                                                                                  name = 'JSON'
                                                                                                                                                  type = 'VariableName' ) ) ) ) ) ) ).

    DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_print_data
                                             compress = abap_true
                                             pretty_name = abap_true
                                             format_output =  abap_true
                                             name_mappings = lt_mappings ).

    TRY.

        DATA(lo_http_destination) = cl_http_destination_provider=>create_by_url( 'https://havensightconsulting.am1.bartendercloud.com/api/actions?wait=20s&messageCount=100&messageSeverity=Info' ).
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ).

        lo_http_client->get_http_request(  )->set_authorization_bearer( i_bearer = lv_string ).
        lo_http_client->get_http_request(  )->set_header_fields( VALUE #(  ( name = if_web_http_header=>content_type value = if_web_http_header=>accept_application_json )
                                                                ( name = if_web_http_header=>accept value = if_web_http_header=>accept_application_json ) ) ).
        lo_http_client->get_http_request(  )->set_text( lv_json ).

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).

        DATA(lv_status) = lo_response->get_status( ).

        DATA(lv_response) = lo_response->get_text(  ).

        DATA(lt_mappings_response) = VALUE /ui2/cl_json=>name_mappings( ( abap = 'id' json = 'Id' )
                                                        ( abap = 'status' json = 'Status' )
                                                        ( abap = 'statusurl' json = 'StatusUrl' )
                                                        ( abap = 'messages' json = 'Messages' ) ).

        /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                             pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                             name_mappings = lt_mappings_response
                                   CHANGING data = ls_response_data ).

        ev_code = lv_status-code.
        TRY .

            SPLIT ls_response_data-messages[ 1 ] AT cl_abap_char_utilities=>horizontal_tab INTO TABLE DATA(lt_messages).
            ev_reason = lt_messages[ 3 ].

          CATCH cx_sy_itab_line_not_found.
            ev_reason = lv_status-reason.
        ENDTRY.


        lo_http_client->close(  ).


      CATCH cx_http_dest_provider_error.
            return.
      CATCH cx_web_http_client_error.
        RETURN.
    ENDTRY.
  ENDMETHOD.


  METHOD upd_matdoc_prnt_tab.

    LOOP AT ct_matdoc_prnt_tab ASSIGNING FIELD-SYMBOL(<fs_matdoc_tab>).
      IF  <fs_matdoc_tab>-order_uuid IS INITIAL.
        TRY.
            <fs_matdoc_tab>-order_uuid = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
          CATCH cx_uuid_error INTO DATA(lo_oref).
            CONTINUE.
        ENDTRY.
      ENDIF.
    ENDLOOP.

    DELETE ct_matdoc_prnt_tab WHERE order_uuid IS INITIAL.

    IF ct_matdoc_prnt_tab IS NOT INITIAL.

      LOOP AT ct_matdoc_prnt_tab ASSIGNING FIELD-SYMBOL(<fs_matdoc_prnt>).
        MODIFY ENTITIES OF zr_seagull_doc_prt
            ENTITY zrseagulldocprt
            CREATE
            SET FIELDS WITH VALUE #( (
                             %cid = <fs_matdoc_prnt>-order_uuid
                             orderuuid = <fs_matdoc_prnt>-order_uuid
                             mblnr = <fs_matdoc_prnt>-mblnr
                             mjahr = <fs_matdoc_prnt>-mjahr
                             nooflabels = <fs_matdoc_prnt>-no_of_labels
                             printername = <fs_matdoc_prnt>-printer_name
                             labelformat = <fs_matdoc_prnt>-label_format
                             printmode = <fs_matdoc_prnt>-print_mode
                             printresponsecode = <fs_matdoc_prnt>-print_response_code
                             printresponsemsg = <fs_matdoc_prnt>-print_response_msg
                             createdby = <fs_matdoc_prnt>-created_by
                             createdat = <fs_matdoc_prnt>-created_at
                             lastchangedby = <fs_matdoc_prnt>-last_changed_by
                             lastchangedat = <fs_matdoc_prnt>-last_changed_at
                             locallastchangedat = <fs_matdoc_prnt>-local_last_changed_at ) )
            MAPPED DATA(ls_mapped)
            FAILED DATA(ls_failed)
            REPORTED DATA(ls_reported).
      ENDLOOP.

      IF iv_commit IS NOT INITIAL.
        COMMIT ENTITIES RESPONSE OF zr_seagull_doc_prt REPORTED DATA(ls_save_reported) FAILED DATA(ls_save_failed).
        IF  ls_save_failed IS INITIAL.
          ev_upd_flag = abap_true.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD get_bearer_token.

    DATA: ls_bearer_token TYPE ty_bearer_token.

    DATA : lt_keys          TYPE TABLE FOR READ IMPORT zr_seagull_cred.

    lt_keys = VALUE #( ( %tky-%key-granttype = 'password' ) ).

    READ ENTITIES OF zr_seagull_cred
     ENTITY zrseagullcred
     ALL FIELDS WITH VALUE #( ( %tky-granttype = 'password' ) )
     RESULT DATA(lt_conn_cred)
     FAILED DATA(lt_failed)
     REPORTED DATA(lt_reported).

    READ TABLE lt_conn_cred ASSIGNING FIELD-SYMBOL(<fs_conn_cred>) INDEX 1.
    IF sy-subrc EQ 0.
      TRY.
          DATA(lo_http_bearer_dest) = cl_http_destination_provider=>create_by_url( CONV #( <fs_conn_cred>-destination ) ).
          DATA(lo_http_bearer_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_bearer_dest ).

          cl_web_http_utility=>escape_url( EXPORTING unescaped = CONV #( <fs_conn_cred>-audience )
          RECEIVING escaped = DATA(lv_escaped_audience) ).

          cl_web_http_utility=>escape_url( EXPORTING unescaped = CONV #( <fs_conn_cred>-clientid )
          RECEIVING escaped = DATA(lv_escaped_client_id) ).

          cl_web_http_utility=>escape_url( EXPORTING unescaped = CONV #( <fs_conn_cred>-clientsecret )
          RECEIVING escaped = DATA(lv_escaped_client_secret) ).


          cl_web_http_utility=>escape_url( EXPORTING unescaped = CONV #( <fs_conn_cred>-username )
                                            RECEIVING escaped = DATA(lv_escaped_username) ).

          cl_web_http_utility=>escape_url( EXPORTING unescaped = CONV #( <fs_conn_cred>-password )
          RECEIVING escaped = DATA(lv_escaped_password) ).


          DATA(lv_fld_val) = 'grant_type=' && <fs_conn_cred>-granttype
                          && '&audience=' && lv_escaped_audience
                          && '&client_id=' && lv_escaped_client_id
                          && '&client_secret=' && lv_escaped_client_secret
                          && '&username=' && lv_escaped_username
                          && '&password=' && lv_escaped_password.

          lo_http_bearer_client->get_http_request(  )->set_text( lv_fld_val ).

          lo_http_bearer_client->get_http_request(  )->set_header_fields( VALUE #(  ( name = if_web_http_header=>content_type value = 'application/x-www-form-urlencoded' ) ) ).

          DATA(lo_bearer_response) = lo_http_bearer_client->execute( if_web_http_client=>post ).
          DATA(lv_bearer_response) = lo_bearer_response->get_text(  ).


          /ui2/cl_json=>deserialize( EXPORTING json = lv_bearer_response
                                               pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                                     CHANGING data = ls_bearer_token ).

          ev_bearer_token = ls_bearer_token-access_token.

          lo_http_bearer_client->close(  ).

        CATCH cx_http_dest_provider_error.
              return.
        CATCH cx_web_http_client_error.
          RETURN.
      ENDTRY.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
