CLASS zseagull_cl_vh_labelformat DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

   types:
         BEGIN OF ty_labelformat_dtl,
             labelformat(100) TYPE c,
           END OF ty_labelformat_dtl,

           tt_labelformat_dtl TYPE STANDARD TABLE OF ty_labelformat_dtl wITH dEFAULT KEY.

    data: it_labelformat_dtl tYPe tt_labelformat_dtl.

    INTERFACES if_rap_query_provider .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZSEAGULL_CL_VH_LABELFORMAT IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA(lo_ref) = NEW zseagull_cl_api_call(  ).
    IF lo_ref IS BOUND.

      lo_ref->get_label_format( IMPORTING et_label_format = it_labelformat_dtl ).

      DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).

      DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
      DATA(lv_max_rows) = COND int8( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                    THEN 0
                                    ELSE lv_page_size ).

      lv_max_rows = lv_skip + lv_page_size.
      IF lv_skip > 0.
        lv_skip = lv_skip + 1.
      ENDIF.

      DATA: it_labelformat_dtl_tmp LIKE it_labelformat_dtl.
      LOOP AT it_labelformat_dtl ASSIGNING FIELD-SYMBOL(<lfs_labelformat_dtl>)
                                 FROM lv_skip TO lv_max_rows.

        APPEND <lfs_labelformat_dtl> TO it_labelformat_dtl_tmp.
      ENDLOOP.

      IF io_request->is_data_requested( ).
        io_response->set_data( it_labelformat_dtl_tmp ).
      ENDIF.

      IF io_request->is_total_numb_of_rec_requested( ).
        io_response->set_total_number_of_records( lines( it_labelformat_dtl ) ).
      ENDIF.

      io_request->get_sort_elements( ).
      io_request->get_paging( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
