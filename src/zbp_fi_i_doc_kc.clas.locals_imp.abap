CLASS lhc_zfi_i_doc_kc DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zfi_i_doc_kc RESULT result.

ENDCLASS.

CLASS lhc_zfi_i_doc_kc IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

ENDCLASS.
