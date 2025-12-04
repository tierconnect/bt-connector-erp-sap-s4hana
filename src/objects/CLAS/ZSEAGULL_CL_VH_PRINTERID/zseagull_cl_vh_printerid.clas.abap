CLASS zseagull_cl_vh_printerid DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
      INTERFACES: if_rap_query_provider.

    TYPES: BEGIN OF ty_printer_dtl,
             printerid(100) TYPE c,
           END OF ty_printer_dtl,

           tt_printer_dtl     TYPE STANDARD TABLE OF ty_printer_dtl.
    class-data:  it_printer_dtl tYPE tt_printer_dtl.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZSEAGULL_CL_VH_PRINTERID IMPLEMENTATION.


  METHOD if_rap_query_provider~select.


    DATA(lo_ref) = NEW zseagull_cl_api_call(  ).

    lo_ref->get_printer_dtl( IMPORTING et_printer_dtl = it_printer_dtl ).

    DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).

    DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
    DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                THEN 0
                                ELSE lv_page_size ).

    lv_max_rows = lv_skip + lv_page_size.
    IF lv_skip > 0.
      lv_skip = lv_skip + 1.
    ENDIF.

    DATA: lt_printer_dtl_tmp LIKE it_printer_dtl.
    LOOP AT it_printer_dtl ASSIGNING FIELD-SYMBOL(<lfs_printer_dtl>)
    FROM lv_skip TO lv_max_rows.

      APPEND <lfs_printer_dtl> TO lt_printer_dtl_tmp.
    ENDLOOP.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_printer_dtl_tmp ).
    ENDIF.

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( it_printer_dtl ) ).
    ENDIF.

    io_request->get_sort_elements( ).
    io_request->get_paging( ).

  ENDMETHOD.
ENDCLASS.
