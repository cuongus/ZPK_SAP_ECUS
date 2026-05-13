CLASS zcl_prc_action_ecus DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_billingdoc,
        billingdocument TYPE string,
      END OF ty_billingdoc,
      tt_billingdoc TYPE STANDARD TABLE OF ty_billingdoc WITH EMPTY KEY,

      tt_ecusitems  TYPE STANDARD TABLE OF zcs_ecus_items WITH EMPTY KEY.

    CLASS-DATA: gt_change_ecusheader TYPE TABLE OF zaecusheader,
                gt_change_ecusitem   TYPE TABLE OF zaecusitems,

                mo_instance          TYPE REF TO zcl_prc_action_ecus.

    CLASS-METHODS : "Contructor.
      get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_prc_action_ecus.

    TYPES: headerchange_keys        TYPE TABLE FOR ACTION IMPORT zcs_ecus_header\\ecusheader~headerchange,
           headerchange_result      TYPE TABLE FOR ACTION RESULT zcs_ecus_header\\ecusheader~headerchange,

           itemchange_keys          TYPE TABLE FOR ACTION IMPORT zcs_ecus_header\\ecusitems~itemchange,
           itemchange_result        TYPE TABLE FOR ACTION RESULT zcs_ecus_header\\ecusitems~itemchange,

           formvgm_keys             TYPE TABLE FOR ACTION IMPORT zcs_ecus_header\\ecusheader~formvgm,
           formvgm_result           TYPE TABLE FOR ACTION RESULT zcs_ecus_header\\ecusheader~formvgm,

           commercialinvoice_keys   TYPE TABLE FOR ACTION IMPORT zcs_ecus_header\\ecusheader~commercialinvoice,
           commercialinvoice_result TYPE TABLE FOR ACTION RESULT zcs_ecus_header\\ecusheader~commercialinvoice,

           formsi_keys              TYPE TABLE FOR ACTION IMPORT zcs_ecus_header\\ecusheader~formsi,
           formsi_result            TYPE TABLE FOR ACTION RESULT zcs_ecus_header\\ecusheader~formsi,

           packinglist_keys         TYPE TABLE FOR ACTION IMPORT zcs_ecus_header\\ecusheader~packinglist,
           packinglist_result       TYPE TABLE FOR ACTION RESULT zcs_ecus_header\\ecusheader~packinglist,

           salescontract_keys       TYPE TABLE FOR ACTION IMPORT zcs_ecus_header\\ecusheader~salescontract,
           salescontract_result     TYPE TABLE FOR ACTION RESULT zcs_ecus_header\\ecusheader~salescontract,

           mapped_early             TYPE RESPONSE FOR MAPPED EARLY zcs_ecus_header,
           failed_early             TYPE RESPONSE FOR FAILED EARLY zcs_ecus_header,
           reported_early           TYPE RESPONSE FOR REPORTED EARLY zcs_ecus_header,

           reported_late            TYPE RESPONSE FOR REPORTED LATE zcs_ecus_header.

    METHODS: replace_characters IMPORTING iv_string        TYPE string
                                RETURNING VALUE(rv_string) TYPE string.

    METHODS:
      headerchange
        IMPORTING keys     TYPE headerchange_keys
        CHANGING  result   TYPE headerchange_result
                  mapped   TYPE mapped_early
                  failed   TYPE failed_early
                  reported TYPE reported_early,

      itemchange
        IMPORTING keys     TYPE itemchange_keys
        CHANGING  result   TYPE itemchange_result
                  mapped   TYPE mapped_early
                  failed   TYPE failed_early
                  reported TYPE reported_early,

      formvgm
        IMPORTING keys     TYPE formvgm_keys
        CHANGING  result   TYPE formvgm_result
                  mapped   TYPE mapped_early
                  failed   TYPE failed_early
                  reported TYPE reported_early,

      commercialinvoice
        IMPORTING keys     TYPE commercialinvoice_keys
        CHANGING  result   TYPE commercialinvoice_result
                  mapped   TYPE mapped_early
                  failed   TYPE failed_early
                  reported TYPE reported_early,

      formsi
        IMPORTING keys     TYPE formsi_keys
        CHANGING  result   TYPE formsi_result
                  mapped   TYPE mapped_early
                  failed   TYPE failed_early
                  reported TYPE reported_early,

      packinglist
        IMPORTING keys     TYPE packinglist_keys
        CHANGING  result   TYPE packinglist_result
                  mapped   TYPE mapped_early
                  failed   TYPE failed_early
                  reported TYPE reported_early,

      salescontract
        IMPORTING keys     TYPE salescontract_keys
        CHANGING  result   TYPE salescontract_result
                  mapped   TYPE mapped_early
                  failed   TYPE failed_early
                  reported TYPE reported_early,

      save CHANGING   reported    TYPE reported_late.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_prc_action_ecus IMPLEMENTATION.


  METHOD headerchange.
    TYPES:
      BEGIN OF lty_change,
        NotifyParty1          TYPE string,
        notifyparty2          TYPE string,
        saillingonorabout     TYPE string,
        depositcontract       TYPE string,
        cylinderquantity      TYPE decfloat34,
        cylinderamount        TYPE decfloat34,
        termofpaymentcontract TYPE string,
        finaldestination      TYPE string,
        estimatedofdelivery   TYPE string,
        billoflading          TYPE string,
        timeofdelivery        TYPE string,     " JSON đang là yyyy-mm-dd
        partialshipment       TYPE string,
        commercialinvoice     TYPE string,
        remarks               TYPE string,
      END OF lty_change,

      BEGIN OF lty_payload,
        items   TYPE tt_billingdoc,
        changes TYPE lty_change,
      END OF lty_payload.

    FREE: gt_change_ecusheader.

    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA: lv_xstring TYPE xstring,
          lv_string  TYPE string,
          ls_json    TYPE lty_payload.

    " Assume lv_xstring is populated with data
    lv_xstring = k-%param-filecontent.

    " Use the XCO library to convert the xstring to a string, specifying the codepage
    " XCO_CP_CHARACTER=>CODE_PAGE->UTF_8 is the standard for cloud environments
    lv_string = xco_cp=>xstring( lv_xstring )->as_string( xco_cp_character=>code_page->utf_8 )->value.

    " lv_string now contains the character representation
    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = lv_string
*       jsonx       =
        pretty_name = /ui2/cl_json=>pretty_mode-user
*       assoc_arrays     =
*       assoc_arrays_opt =
*       name_mappings    =
*       conversion_exits =
*       hex_as_base64    =
      CHANGING
        data        = ls_json
    ).

    DATA: ls_ecusheader TYPE zaecusheader.

    ls_ecusheader-billingdocument       = ls_json-items[ 1 ]-billingdocument.

    ls_ecusheader-NotifyParty1          = ls_json-changes-NotifyParty1.
    ls_ecusheader-notifyparty2          = ls_json-changes-notifyparty2.
    "2026-03-25
    IF ls_json-changes-saillingonorabout IS NOT INITIAL.
      ls_ecusheader-saillingonorabout     =
      ls_json-changes-saillingonorabout+0(4)
      && ls_json-changes-saillingonorabout+5(2)
      && ls_json-changes-saillingonorabout+8(2).
    ENDIF.

    ls_ecusheader-depositcontract       = ls_json-changes-depositcontract.
    ls_ecusheader-cylinderquantity      = ls_json-changes-cylinderquantity.
    ls_ecusheader-cylinderamount        = ls_json-changes-cylinderamount.
    ls_ecusheader-termofpaymentcontract = ls_json-changes-termofpaymentcontract.

    ls_ecusheader-finaldestination = ls_json-changes-finaldestination.

    IF ls_json-changes-estimatedofdelivery IS NOT INITIAL.
      ls_ecusheader-estimatedofdelivery        =
      ls_json-changes-estimatedofdelivery+0(4)
      && ls_json-changes-estimatedofdelivery+5(2)
      && ls_json-changes-estimatedofdelivery+8(2).
    ENDIF.

    IF ls_json-changes-timeofdelivery IS NOT INITIAL.
      ls_ecusheader-timeofdelivery        =
      ls_json-changes-timeofdelivery+0(4)
      && ls_json-changes-timeofdelivery+5(2)
      && ls_json-changes-timeofdelivery+8(2).
    ENDIF.

    ls_ecusheader-billoflading          = ls_json-changes-billoflading.
    ls_ecusheader-partialshipment       = ls_json-changes-partialshipment.
    ls_ecusheader-commercialinvoice     = ls_json-changes-commercialinvoice.
    ls_ecusheader-Remarks               = ls_json-changes-Remarks.

    ls_ecusheader-local_last_changed_by = sy-uname.
    ls_ecusheader-local_last_changed_at = sy-datlo && sy-timlo.
    ls_ecusheader-last_changed_at = sy-datum && sy-uzeit.

    APPEND ls_ecusheader TO gt_change_ecusheader.

  ENDMETHOD.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                               THEN mo_instance
                                               ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD save.

    IF gt_change_ecusheader IS NOT INITIAL.
      MODIFY zaecusheader FROM TABLE @gt_change_ecusheader.
    ENDIF.
    FREE: gt_change_ecusheader.

    IF gt_change_ecusitem IS NOT INITIAL.
      MODIFY zaecusitems FROM TABLE @gt_change_ecusitem.
    ENDIF.
    FREE: gt_change_ecusitem.

  ENDMETHOD.


  METHOD itemchange.
    TYPES:
      BEGIN OF lty_change_item,
        billingdocument     TYPE string,
        billingdocumentitem TYPE string,
        customerpo          TYPE string,
        customeritemnostyle TYPE string,
        commoditysku        TYPE string,
        hscode              TYPE string,
        lotno               TYPE string,
        pallet              TYPE decfloat34,
        TareWeight          TYPE decfloat34,
        sortitempackinglist TYPE string,
      END OF lty_change_item,

      tt_change_item TYPE STANDARD TABLE OF lty_change_item WITH EMPTY KEY,

      BEGIN OF lty_payload,
        items TYPE tt_change_item,
      END OF lty_payload.

    FREE: gt_change_ecusitem.

    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA: lv_xstring TYPE xstring,
          lv_string  TYPE string,
          ls_json    TYPE lty_payload.

    " Assume lv_xstring is populated with data
    lv_xstring = k-%param-filecontent.

    " Use the XCO library to convert the xstring to a string, specifying the codepage
    " XCO_CP_CHARACTER=>CODE_PAGE->UTF_8 is the standard for cloud environments
    lv_string = xco_cp=>xstring( lv_xstring )->as_string( xco_cp_character=>code_page->utf_8 )->value.

    " lv_string now contains the character representation
    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = lv_string
*       jsonx       =
        pretty_name = /ui2/cl_json=>pretty_mode-user
*       assoc_arrays     =
*       assoc_arrays_opt =
*       name_mappings    =
*       conversion_exits =
*       hex_as_base64    =
      CHANGING
        data        = ls_json
    ).

    DATA: ls_change_ecusitem LIKE LINE OF gt_change_ecusitem.

    LOOP AT ls_json-items INTO DATA(ls_item).
      ls_change_ecusitem-billingdocument     = ls_item-billingdocument.
      ls_change_ecusitem-billingdocumentitem = ls_item-billingdocumentitem.
      ls_change_ecusitem-customerpo          = ls_item-customerpo.
      ls_change_ecusitem-hscode              = ls_item-hscode.
      ls_change_ecusitem-lotno               = ls_item-lotno.
      ls_change_ecusitem-pallet              = ls_item-pallet.
      ls_change_ecusitem-tareweight          = ls_item-tareweight.
      ls_change_ecusitem-sortitempackinglist = ls_item-sortitempackinglist.

      ls_change_ecusitem-customeritemnostyle = ls_item-customeritemnostyle.
      ls_change_ecusitem-commoditysku        = ls_item-commoditysku.

      ls_change_ecusitem-local_last_changed_by = sy-uname.
      ls_change_ecusitem-local_last_changed_at = sy-datlo && sy-timlo.
      ls_change_ecusitem-last_changed_at = sy-datum && sy-uzeit.

      APPEND ls_change_ecusitem TO gt_change_ecusitem.
      CLEAR: ls_change_ecusitem.
    ENDLOOP.

  ENDMETHOD.


  METHOD formvgm.
    TYPES:
      BEGIN OF lty_containerrow,
        billingdocument     TYPE i_billingdocument-billingdocument,
        billingdocumentitem TYPE i_billingdocumentitem-billingdocumentitem,
        placedate           TYPE string,
        containerno         TYPE string,
        containersealno     TYPE string,
        verifiedgweight     TYPE string,
      END OF lty_containerrow,

      BEGIN OF lty_change,
        placedate    TYPE string,
        containerrow TYPE STANDARD TABLE OF lty_containerrow WITH EMPTY KEY,
      END OF lty_change,

      BEGIN OF lty_change_payload,
        change TYPE lty_change,
      END OF lty_change_payload,

      BEGIN OF lty_temp_container,
        containerno     TYPE string,
        containersealno TYPE string,
        verifiedgweight TYPE string,
      END OF lty_temp_container.

    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA: lt_temp_container TYPE SORTED TABLE OF lty_temp_container WITH NON-UNIQUE KEY containerno containersealno.
    DATA: lv_xstring TYPE xstring,
          lv_string  TYPE string,
          ls_json    TYPE lty_change_payload.

    " Assume lv_xstring is populated with data
    lv_xstring = k-%param-filecontent.

    " Use the XCO library to convert the xstring to a string, specifying the codepage
    " XCO_CP_CHARACTER=>CODE_PAGE->UTF_8 is the standard for cloud environments
    lv_string = xco_cp=>xstring( lv_xstring )->as_string( xco_cp_character=>code_page->utf_8 )->value.

    " lv_string now contains the character representation
    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = lv_string
*       jsonx       =
        pretty_name = /ui2/cl_json=>pretty_mode-user
*       assoc_arrays     =
*       assoc_arrays_opt =
*       name_mappings    =
*       conversion_exits =
*       hex_as_base64    =
      CHANGING
        data        = ls_json
    ).

    DATA: ir_billingdocument TYPE zcl_app_ecus_data=>tt_ranges.

    "Log Data
    LOOP AT ls_json-change-containerrow INTO DATA(ls_change).
      APPEND VALUE #(
         billingdocument     = ls_change-billingdocument
         billingdocumentitem = ls_change-billingdocumentitem
         verifiedgweight     = ls_change-verifiedgweight
      ) TO gt_change_ecusitem.

      APPEND VALUE #( sign = 'I' option = 'EQ' low = ls_change-billingdocument ) TO ir_billingdocument.

      READ TABLE lt_temp_container TRANSPORTING NO FIELDS WITH KEY containerno     = ls_change-containerno
                                                                   containersealno = ls_change-containersealno BINARY SEARCH.
      IF sy-subrc NE 0.
        INSERT VALUE #(
                containerno     = ls_change-containerno
                containersealno = ls_change-containersealno
                verifiedgweight = ls_change-verifiedgweight
        ) INTO TABLE lt_temp_container.
      ENDIF.
    ENDLOOP.

    "Get data
    zcl_app_ecus_data=>get_instance( )->get_data_app_ecus(
        EXPORTING
        ir_billingdocument = ir_billingdocument
        IMPORTING
        et_ecus_header = DATA(lt_ecus_header)
        et_ecus_items = DATA(lt_ecus_item)
    ).

    "Quickly XML Generate --> "---\
    DATA: ls_xml TYPE zcl_gen_adobe=>ty_gs_xml.

    DATA: lv_xml             TYPE string,
          lv_table_xml       TYPE string,
          lv_date            TYPE string,
          lv_shipper         TYPE string,
          lv_maxgrossweight  TYPE string,
          lv_containerno     TYPE string,
          lv_typeptvt        TYPE string,
          lv_shippervgm      TYPE string,
          lv_verifiedgweight TYPE string.

    DATA: lv_index TYPE int4 VALUE IS INITIAL.

    TYPES: BEGIN OF lty_line,
             stt             TYPE string,
             containerno     TYPE string,
             sizeofcontainer TYPE string,
             maxgrossweight  TYPE string,
             verifiedgweight TYPE string,
             nameandaddress  TYPE string,
           END OF lty_line,

           BEGIN OF lty_containerpaticular,
             line TYPE STANDARD TABLE OF lty_line WITH NON-UNIQUE KEY table_line,
           END OF lty_containerpaticular,

           BEGIN OF lty_header,
             date    TYPE string,
             shipper TYPE string,
           END OF lty_header,

           BEGIN OF lty_table,
             containerpaticular TYPE lty_containerpaticular,
           END OF lty_table,

           BEGIN OF lty_main,
             header TYPE lty_header,
             table  TYPE lty_table,
           END OF lty_main.

    TYPES: BEGIN OF lty_form,
             main TYPE lty_main,
           END OF lty_form.

    DATA: form TYPE lty_form.

    DATA lt_alias TYPE zcl_xdp_parser=>ty_t_alias.

    lt_alias = VALUE #(
      ( from = 'Main'                to = 'main' )
      ( from = 'Header'              to = 'header' )
      ( from = 'Date'                to = 'date' )
      ( from = 'Shipper'             to = 'shipper' )
      ( from = 'Table'               to = 'table' )
      ( from = 'ContainerParticular' to = 'containerpaticular' ) "typo của bạn
      ( from = 'Line'                to = 'line' )
      ( from = 'STT'                 to = 'stt' )
      ( from = 'ContainerNo'         to = 'containerno' )
      ( from = 'SizeOfContainer'     to = 'sizeofcontainer' )
      ( from = 'MaxGrossWeight'      to = 'maxgrossweight' )
      ( from = 'VerifiedGWeight'     to = 'verifiedgweight' )
      ( from = 'NameAndAddress'      to = 'nameandaddress' )
    ).

    "---------------------------------------------------"

    "PDF Instance
    DATA: str_pdf     TYPE string,
          formin_name TYPE string,
          lv_pdf      TYPE xstring.
    DATA(lv_pdf_merge) = cl_rspo_pdf_merger=>create_instance( ).

    DATA(lv_sdate) = ls_json-change-placedate.

    IF lv_sdate IS NOT INITIAL.
      REPLACE ALL OCCURRENCES OF '-' IN lv_sdate WITH ''.
    ENDIF.

    SORT ls_json-change-containerrow BY containerno containersealno ASCENDING.

    DATA: lv_filled TYPE abap_boolean.

    "Process data - Create XML
    LOOP AT lt_ecus_header INTO DATA(ls_ecus_header).
      "---\
      CLEAR: form.
      "---\

      CLEAR: lv_index.
      CASE ls_ecus_header-salesorganization.

        WHEN '6710'.
          IF lv_sdate IS NOT INITIAL.
            lv_date = |Ninh Bình, ngày { lv_sdate+6(2) } tháng { lv_sdate+4(2) } năm { lv_sdate+0(4) }|.
          ELSE.
            lv_date = |Ninh Bình, ngày.... tháng.... năm.... |.
          ENDIF.
          formin_name = 'FormVGMCasla'.
        WHEN '6720'.
          IF lv_sdate IS NOT INITIAL.
            lv_date = |Bắc Ninh, ngày { lv_sdate+6(2) } tháng { lv_sdate+4(2) } năm { lv_sdate+0(4) }|.
          ELSE.
            lv_date = |Bắc Ninh, ngày.... tháng... năm.... |.
          ENDIF.
          formin_name = 'FormVGMCasa'.
        WHEN OTHERS.
      ENDCASE.

      lv_shipper = `1. Tên người gửi hàng, địa chỉ, số điện thoại/ ` &&
      `Name of shipper, address, phone number: `
      && ls_ecus_header-shippervgm && ` ` && ls_ecus_header-addressvgm.

      lv_shipper = me->replace_characters( EXPORTING iv_string = lv_shipper ).

      "---\
      form-main-header-date = lv_date.
      form-main-header-shipper = lv_shipper.
      "---\

      "---Group BY
      LOOP AT lt_ecus_item INTO DATA(ls_ecus_item)
        WHERE billingdocument = ls_ecus_header-billingdocument
        GROUP BY (
          containerno      = ls_ecus_item-containerno
          containersealno  = ls_ecus_item-containersealno
        )
        ASCENDING
        ASSIGNING FIELD-SYMBOL(<group>).

        lv_containerno = |{ <group>-containerno }/{ <group>-containersealno }|.
        lv_containerno = me->replace_characters( EXPORTING iv_string = lv_containerno ).

        "Thay đổi logic verifiedgweight - Date 29.04.2026 - AK3K905104
*        READ TABLE lt_temp_container INTO DATA(ls_temp_container) WITH KEY containerno = <group>-containerno
*                                                                           containersealno = <group>-containersealno BINARY SEARCH.
*        IF sy-subrc EQ 0.
*          lv_verifiedgweight = ls_temp_container-verifiedgweight.
*        ENDIF.

        "---
        lv_filled = abap_false.

        LOOP AT GROUP <group> INTO DATA(ls_group).

          IF lv_filled = abap_false.

            lv_filled = abap_true.
            lv_index = lv_index + 1.

            CASE ls_group-typeptvt.
              WHEN '20'.
                lv_maxgrossweight = '30500'.
              WHEN '40' OR '45'.
                lv_maxgrossweight = '32500'.
              WHEN OTHERS.
                lv_maxgrossweight = ''.
            ENDCASE.

            lv_typeptvt = ls_group-typeptvt.
            lv_typeptvt = me->replace_characters( EXPORTING iv_string = lv_typeptvt ).

            lv_shippervgm = ls_ecus_header-shippervgm.
            lv_shippervgm = me->replace_characters( EXPORTING iv_string = lv_shippervgm ).

            lv_verifiedgweight = ls_group-TareWeight + ls_group-Gweight.

            "---\
            APPEND VALUE #(
                stt             = lv_index
                containerno     = lv_containerno
                sizeofcontainer = lv_typeptvt
                maxgrossweight  = lv_maxgrossweight
                verifiedgweight = lv_verifiedgweight
                nameandaddress  = lv_shippervgm
            )
            TO form-main-table-containerpaticular-line.
            "---\
            CLEAR: lv_maxgrossweight.
          ELSE.
            READ TABLE form-main-table-containerpaticular-line ASSIGNING FIELD-SYMBOL(<ls_line>)
            WITH KEY containerno = lv_containerno.
            IF sy-subrc EQ 0.
              <ls_line>-verifiedgweight = <ls_line>-verifiedgweight + ls_group-Gweight.
            ENDIF.
          ENDIF. "EndIF logic chỉ lấy 1 dòng Container
        ENDLOOP. "---End Loop In Group

      ENDLOOP. "--- End Group By

    ENDLOOP. "--- End loop Header

    DATA: xml_xstring TYPE xstring.
*-- "Get template a
    SELECT SINGLE file_content
    FROM zcore_tb_temppdf
    WHERE id = @formin_name
    INTO @DATA(lv_xdp_file).

    DATA: lv_xdp_layout TYPE xstring.
    lv_xdp_layout = lv_xdp_file.

    "---\
    TRY.
        DATA(nodes) = zcl_xdp_parser=>parse(
          i_xdp_xstr    = lv_xdp_layout
          i_filter_root = '/Form/Main' ).

*        DATA(lv_xml) = zcl_xdp_parser=>build_template_from_nodes(
*          it_nodes     = nodes
*          iv_root_trim = '/xdp/template' ).

        DATA(lv_quick_xml) = zcl_xdp_parser=>build_xml_from_form_data(
          it_nodes     = nodes
          is_form      = form
          it_alias     = lt_alias
          iv_root_trim = '/xdp/template' ).

      CATCH cx_root.
        "handle exception
    ENDTRY.
    "---\

*      xml_xstring = cl_abap_conv_codepage=>create_out(
*        codepage = 'UTF-8'
*                   )->convert( source = lv_quick_xml ).

    xml_xstring = lv_quick_xml.

    DATA: lv_xml_string  TYPE string.

    lv_xml_string = cl_abap_conv_codepage=>create_in(
      codepage = 'UTF-8'
                 )->convert( source = xml_xstring ).

    TRY.
        "render PDF
        cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data     = xml_xstring
                                              iv_xdp_layout   = lv_xdp_layout
                                              iv_locale       = 'de_DE'
                                              is_options      = VALUE #( embed_fonts = 'X' )
                                    IMPORTING ev_pdf          = DATA(ev_pdf)
                                              ev_pages        = DATA(ev_pages)
                                              ev_trace_string = DATA(ev_trace_string)
                                             ).
        "add PDF will merge
        lv_pdf_merge->add_document( ev_pdf ).

      CATCH cx_fp_ads_util INTO DATA(lx_fp_ads_util).
        "handle exception
        DATA(lv_error) = lx_fp_ads_util->get_longtext( ).
    ENDTRY.

    CLEAR: lv_xml, xml_xstring, form.

    DATA: lv_return           TYPE xstring.

    TRY.
        "merge PDF
        lv_return   = lv_pdf_merge->merge_documents( ).
        str_pdf      = cl_web_http_utility=>encode_x_base64( lv_return ).
      CATCH cx_rspo_pdf_merger INTO DATA(lx_rspo_pdf_merger).
        "handle exception
        lv_error = lx_fp_ads_util->get_longtext( ).
    ENDTRY.

    "Generate PDF
*    DATA(lv_pdf) = zcl_gen_adobe=>get_instance( )->print_pdf( EXPORTING i_xml   = ls_xml
*                                                     iv_rpid = formin_name
*                                           IMPORTING str_pdf = str_pdf ).

    "Export - Result
    DATA: lv_name TYPE string.

    lv_name = |FormInVGM_{ sy-datlo }{ sy-timlo }|.

    result = VALUE #(
                    FOR key IN keys (
*                       %cid_ref = key-%cid_ref
*                       %tky   = key-%tky
                    %cid   = k-%cid
                    %param = VALUE #( filecontent   = str_pdf
                                      filename      = lv_name
                                      fileextension = 'pdf'
*                                              mimeType      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                      mimetype      = 'application/pdf'
                                      )
                    )
                    ).

    DATA: ls_mapped LIKE LINE OF mapped-ecusheader.
*    ls_mapped-%tky         = k-%tky.

    INSERT CORRESPONDING #( ls_mapped ) INTO TABLE mapped-ecusheader.

  ENDMETHOD.


  METHOD replace_characters.

    "Return value
    rv_string = iv_string.

    "Replace Ký tự lỗi
    REPLACE ALL OCCURRENCES OF '&' IN rv_string WITH '&amp;'.
    REPLACE ALL OCCURRENCES OF '<' IN rv_string WITH '&lt;'.
    REPLACE ALL OCCURRENCES OF '>' IN rv_string WITH '&gt;'.

  ENDMETHOD.


  METHOD commercialinvoice.

  ENDMETHOD.


  METHOD formsi.

  ENDMETHOD.


  METHOD packinglist.

  ENDMETHOD.


  METHOD salescontract.

  ENDMETHOD.
ENDCLASS.
