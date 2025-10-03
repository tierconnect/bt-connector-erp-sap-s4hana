CLASS zseagull_cl_vh_printerid DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZSEAGULL_CL_VH_PRINTERID IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA(lo_ref) = NEW zseagull_cl_api_call(  ).

    lo_ref->get_printer_dtl( IMPORTING et_printer_dtl = DATA(lt_printer_dtl) ).

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_printer_dtl ).
    ENDIF.

    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_printer_dtl ) ).
    ENDIF.

    io_request->get_sort_elements( ).
    io_request->get_paging( ).

  ENDMETHOD.
ENDCLASS.
