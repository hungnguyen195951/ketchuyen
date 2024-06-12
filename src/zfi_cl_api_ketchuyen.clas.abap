CLASS zfi_cl_api_ketchuyen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_request_item,
        item       TYPE string,
        postingkey TYPE string,
        amount     TYPE string,
        currency   TYPE string,
        glacount   TYPE string,
        costcenter TYPE string,
      END OF ty_request_item,
      BEGIN OF ty_request,
        isreverse          TYPE string,
        accountingdocument TYPE string,
        company_Code       TYPE string,
        documen_Type       TYPE string,
        posting_Date       TYPE string,
        document_Date      TYPE string,
        fiscal_Year        TYPE string,
        fiscal_Period      TYPE string,
        rule_type          TYPE string,
        items              TYPE STANDARD TABLE OF ty_request_item WITH EMPTY KEY,
      END OF ty_request,
      BEGIN OF ty_data_item,
        item       TYPE int4,
        postingkey TYPE I_JournalEntryItem-PostingKey,
        amount     TYPE I_JournalEntryItem-AmountInCompanyCodeCurrency,
        currency   TYPE waers,
        glacount   TYPE I_JournalEntryItem-GLAccount,
        costcenter TYPE I_JournalEntryItem-CostCenter,
      END OF ty_data_item,
      BEGIN OF ty_data,
        accountingdocument TYPE belnr_d,
        company_Code       TYPE bukrs,
        documen_Type       TYPE blart,
        posting_Date       TYPE budat,
        document_Date      TYPE budat,
        fiscal_Year        TYPE gjahr,
        fiscal_Period      TYPE fins_fiscalperiod,
        rule_type          TYPE zde_rulty,
        items              TYPE STANDARD TABLE OF ty_data_item WITH EMPTY KEY,
      END OF ty_data,
      BEGIN OF ty_messages,
        message TYPE string,
        type    TYPE string,
      END OF ty_messages,
      BEGIN OF ty_respone,
        accountingdocument TYPE belnr_d,
        fiscalyear         TYPE gjahr,
        companycode        TYPE bukrs,
        messages           TYPE STANDARD TABLE OF ty_messages WITH EMPTY KEY,
      END OF ty_respone.
    DATA:
      request_data  TYPE ty_request,
      response_data TYPE ty_respone,
      gs_data       TYPE ty_data.
    METHODS:
      post_fidoc,
      cancel_fidoc,
      check_data.
ENDCLASS.



CLASS ZFI_CL_API_KETCHUYEN IMPLEMENTATION.


  METHOD cancel_fidoc.
    gs_data = CORRESPONDING #( request_data EXCEPT items ).
    gs_data-accountingdocument = |{ request_data-accountingdocument ALPHA = IN }|.
    TRY.
        DATA(lv_cid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
      CATCH cx_uuid_error.
    ENDTRY.
    DATA: ls_message TYPE ty_messages.

    DATA: lt_validate TYPE TABLE FOR FUNCTION IMPORT i_journalentrytp~Validate.
    APPEND INITIAL LINE TO lt_validate REFERENCE INTO DATA(ls_validate).
    ls_validate->%cid = lv_cid.
    ls_validate->%param = VALUE #(
    AccountingDocument = gs_data-accountingdocument
    CompanyCode = gs_data-company_code
    PostingDate = gs_data-posting_date
    ReversalReason = '01'
    ReversalReferenceDocumentKey = |{ gs_data-accountingdocument }{ gs_data-company_code }{ gs_data-fiscal_year }|
    CreatedByUser = sy-uname
     ).
    READ ENTITIES OF i_journalentrytp
    ENTITY journalentry
    EXECUTE validate FROM lt_validate
      RESULT DATA(lt_check_result)
      FAILED DATA(ls_failed_chk)
      REPORTED DATA(ls_reported_chk).
    IF  ls_failed_chk IS NOT INITIAL.
      LOOP AT ls_reported_chk-journalentry REFERENCE INTO DATA(ls_validate_rep).
        CASE ls_validate_rep->%msg->if_t100_dyn_msg~msgty.
          WHEN 'E'. ls_message-type = 'Error'.
          WHEN 'S'. ls_message-type = 'Success'.
          WHEN 'W'. ls_message-type = 'Warning'.
        ENDCASE.
        ls_message-message = ls_validate_rep->%msg->if_message~get_text( ).
        APPEND ls_message TO response_data-messages.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA:
       lt_reverse TYPE TABLE FOR ACTION IMPORT i_journalentrytp~Reverse.

    APPEND INITIAL LINE TO lt_reverse REFERENCE INTO DATA(ls_reverse).
    ls_reverse->companycode = gs_data-company_code.
    ls_reverse->fiscalyear = gs_data-fiscal_year.
    ls_reverse->accountingdocument = gs_data-accountingdocument.
    ls_reverse->%param = VALUE #(
                          postingdate = gs_data-posting_date
                          reversalreason = '01'
                          createdbyuser = sy-uname

                          ).
    MODIFY ENTITIES OF i_journalentrytp
    ENTITY journalentry
    EXECUTE reverse FROM lt_reverse
    FAILED DATA(failed)
    REPORTED DATA(reported)
    MAPPED DATA(mapped).

    IF failed IS NOT INITIAL.
      ls_message-message = 'Error exists'.
      ls_message-type = 'Error'.
      APPEND ls_message TO response_data-messages.
      LOOP AT reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_report_journal>).
        CASE <ls_report_journal>-%msg->if_t100_dyn_msg~msgty.
          WHEN 'E'. ls_message-type = 'Error'.
          WHEN 'S'. ls_message-type = 'Success'.
          WHEN 'W'. ls_message-type = 'Warning'.
        ENDCASE.
        ls_message-message = <ls_report_journal>-%msg->if_message~get_text( ).
        APPEND ls_message TO response_data-messages.
      ENDLOOP.
    ELSE.
      COMMIT ENTITIES BEGIN
       RESPONSE OF i_journalentrytp
       FAILED DATA(lt_commit_failed)
       REPORTED DATA(lt_commit_reported).
      TYPES:
        BEGIN OF lty_accountingdocument,
          accountingdocument TYPE belnr_d,
          companycode        TYPE bukrs,
          fiscalyear         TYPE gjahr,
        END OF lty_accountingdocument.
      DATA: ls_accountingdocument   TYPE lty_accountingdocument.
      LOOP AT mapped-journalentry REFERENCE INTO DATA(ls_journal_map_key).
        CONVERT KEY OF i_journalentrytp FROM ls_journal_map_key->%pid TO DATA(lv_key).
        ls_accountingdocument-companycode = lv_key-companycode.
        ls_accountingdocument-fiscalyear = lv_key-fiscalyear.
        ls_accountingdocument-accountingdocument = lv_key-accountingdocument.
        UPDATE zfi_tb_kc SET iscan = 'X',
                               can_date = @sy-datum,
                               can_user = @sy-uname
                           WHERE companycode = @gs_data-company_code
                            AND fiscalyear = @gs_data-fiscal_year
                            AND period = @gs_data-fiscal_period
                            AND rulty = @gs_data-rule_type
                            AND belnr = @gs_data-accountingdocument.
        COMMIT WORK AND WAIT.
        READ TABLE lt_commit_reported-journalentry INTO DATA(ls_commit_reported)
        WITH KEY %pid = ls_journal_map_key->%pid.
        IF sy-subrc = 0.
          ls_message-message = ls_commit_reported-%msg->if_message~get_text( ).
          CASE ls_commit_reported-%msg->if_t100_dyn_msg~msgty.
            WHEN 'E'. ls_message-type = 'Error'.
            WHEN 'S'. ls_message-type = 'Success'.
            WHEN 'W'. ls_message-type = 'Warning'.
          ENDCASE.
          APPEND ls_message TO response_data-messages.
        ENDIF.
      ENDLOOP.
      COMMIT ENTITIES END.

    ENDIF.
  ENDMETHOD.


  METHOD check_data.
    gs_data = CORRESPONDING #( request_data EXCEPT items ).
    LOOP AT request_data-items REFERENCE INTO DATA(ls_item).

      APPEND VALUE #(
          item = ls_item->item
          amount = COND #( WHEN ls_item->currency = 'VND' THEN ls_item->amount / 100 ELSE ls_item->amount )
          costcenter = ls_item->costcenter
          glacount = |{ ls_item->glacount ALPHA = IN }|
          currency = ls_item->currency
          postingkey = ls_item->postingkey
      ) TO gs_data-items.
    ENDLOOP.
  ENDMETHOD.


  METHOD if_http_service_extension~handle_request.
*$-----------------------------------------------------------$
* Handle request
*$-----------------------------------------------------------$
    DATA:
      request_method TYPE string,
      request_body   TYPE string,
      response_body  TYPE string.

    request_method = request->get_header_field( i_name = '~request_method' ).
    request_body = request->get_text( ).

    CASE request_method.
      WHEN 'POST'.
*---$ Get request
        xco_cp_json=>data->from_string( request_body )->apply( VALUE #(
      ( xco_cp_json=>transformation->camel_case_to_underscore ) ) )->write_to( REF #( request_data ) ).

*---$ Call post FI Document
        IF  request_data-isreverse = 'X'. "Cancel
          cancel_fidoc( ).
        ELSE. "Post
          check_data( ).
          post_fidoc( ).
        ENDIF.

*---$ Set response
        response_body = xco_cp_json=>data->from_abap( response_data )->apply( VALUE #(
        ( xco_cp_json=>transformation->underscore_to_camel_case )
        ) )->to_string( ).
        response->set_text( i_text = response_body ).
      WHEN 'GET'.

    ENDCASE.
  ENDMETHOD.


  METHOD post_fidoc.
    TRY.
        DATA(lv_cid) = cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ).
      CATCH cx_uuid_error.
    ENDTRY.
    DATA:
         lt_post TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post.
    SELECT DISTINCT
      i_postingkey~postingkey,
      i_postingkey~financialaccounttype,
      i_postingkey~debitcreditcode
     FROM i_postingkey
     INNER JOIN @gs_data-items AS item ON item~postingkey = i_postingkey~postingkey
     ORDER BY i_postingkey~postingkey
     INTO TABLE @DATA(lt_postingkey).
    APPEND INITIAL LINE TO lt_post REFERENCE INTO DATA(ls_post).
    ls_post->%param-CreatedByUser = sy-uname.
    ls_post->%param-CompanyCode = gs_data-company_code.
    ls_post->%param-PostingDate = gs_data-posting_date.
    ls_post->%param-DocumentDate = gs_data-document_date.
    ls_post->%param-AccountingDocumentType = gs_data-documen_type.
    ls_post->%cid = lv_cid.

    LOOP AT gs_data-items REFERENCE INTO DATA(ls_item).
      READ TABLE lt_postingkey INTO DATA(ls_postingkey)
          WITH KEY postingkey = ls_item->postingkey BINARY SEARCH.
      IF sy-subrc = 0.
        APPEND INITIAL LINE TO ls_post->%param-_glitems REFERENCE INTO DATA(ls_glitem).
        ls_glitem->GLAccountLineItem = ls_item->item.
        ls_glitem->GLAccount = ls_item->glacount.
        ls_glitem->CostCenter = ls_item->costcenter.
        ls_glitem->_currencyamount = VALUE #( ( currencyrole = '00'
                                      journalentryitemamount = COND #( WHEN ls_postingkey-debitcreditcode = 'H' THEN ls_item->amount * -1 ELSE ls_item->amount )
                                      currency = ls_item->currency ) ).
      ENDIF.
    ENDLOOP.
    DATA: ls_message TYPE ty_messages.
    MODIFY ENTITIES OF i_journalentrytp
    ENTITY journalentry
    EXECUTE post FROM lt_post
    FAILED DATA(failed)
    REPORTED DATA(reported)
    MAPPED DATA(mapped).
    IF failed IS NOT INITIAL.
      LOOP AT reported-journalentry ASSIGNING FIELD-SYMBOL(<ls_report_journal>).
        CASE <ls_report_journal>-%msg->if_t100_dyn_msg~msgty.
          WHEN 'E'. ls_message-type = 'Error'.
          WHEN 'S'. ls_message-type = 'Success'.
          WHEN 'W'. ls_message-type = 'Warning'.
        ENDCASE.
        ls_message-message = <ls_report_journal>-%msg->if_message~get_text( ).
        APPEND ls_message TO response_data-messages.
      ENDLOOP.
    ELSE.
*    --$ commit

      COMMIT ENTITIES BEGIN
       RESPONSE OF i_journalentrytp
       FAILED DATA(lt_commit_failed)
       REPORTED DATA(lt_commit_reported).
      COMMIT ENTITIES END.
      TYPES:
        BEGIN OF lty_accountingdocument,
          accountingdocument TYPE belnr_d,
          companycode        TYPE bukrs,
          fiscalyear         TYPE gjahr,
        END OF lty_accountingdocument.
      DATA: ls_accountingdocument   TYPE lty_accountingdocument.
      LOOP AT mapped-journalentry REFERENCE INTO DATA(ls_journal_map_key).
        READ TABLE lt_commit_reported-journalentry INTO DATA(ls_commit_reported)
        WITH KEY %pid = ls_journal_map_key->%pid.
        IF sy-subrc = 0.
          ls_message-message = ls_commit_reported-%msg->if_message~get_text( ).
          CASE ls_commit_reported-%msg->if_t100_dyn_msg~msgty.
            WHEN 'E'. ls_message-type = 'Error'.
            WHEN 'S'. ls_message-type = 'Success'.
            WHEN 'W'. ls_message-type = 'Warning'.
          ENDCASE.
          APPEND ls_message TO response_data-messages.
          ls_accountingdocument = ls_commit_reported-%msg->if_t100_dyn_msg~msgv2.
          DATA: ls_tb_kc TYPE zfi_tb_kc.
          ls_tb_kc-companycode = gs_data-company_code.
          ls_tb_kc-fiscalyear = gs_data-fiscal_Year.
          ls_tb_kc-period = gs_data-fiscal_period.
          ls_tb_kc-rulty = gs_data-rule_type.
          ls_tb_kc-belnr = ls_accountingdocument-accountingdocument.
          ls_tb_kc-postingdate = gs_data-posting_date.
          ls_tb_kc-pst_date = sy-datum.
          ls_tb_kc-pst_user = sy-uname.
          MODIFY zfi_tb_kc FROM @ls_tb_kc.
          COMMIT WORK .
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
