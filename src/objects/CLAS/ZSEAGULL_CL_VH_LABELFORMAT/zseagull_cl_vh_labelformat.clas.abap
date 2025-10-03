CLASS zseagull_cl_vh_labelformat DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zseagull_cl_vh_labelformat IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA(lo_ref) = NEW zseagull_cl_api_call(  ).
    IF lo_ref IS BOUND.

      lo_ref->get_label_format( IMPORTING et_label_format = DATA(lt_labelformat_dtl) ).

      IF io_request->is_data_requested( ).
        io_response->set_data( lt_labelformat_dtl ).
      ENDIF.

      IF io_request->is_total_numb_of_rec_requested( ).
        io_response->set_total_number_of_records( lines( lt_labelformat_dtl ) ).
      ENDIF.

      io_request->get_sort_elements( ).
      io_request->get_paging( ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
