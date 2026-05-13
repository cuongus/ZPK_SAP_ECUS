CLASS zcl_print_form_ecus DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option,

           BEGIN OF ty_attachment,
             mimetype      TYPE zi_file_abs-mimetype,
             filename      TYPE zi_file_abs-filename,
             filecontent   TYPE zi_file_abs-filecontent,
             fileextension TYPE zi_file_abs-fileextension,
           END OF ty_attachment,

           ts_attachment TYPE ty_attachment,
           tt_ranges     TYPE TABLE OF ty_range_option,

           tt_items      TYPE TABLE OF zcs_ecus_items.

    CLASS-DATA:
              mo_instance TYPE REF TO zcl_print_form_ecus.

    CLASS-METHODS:
      "Contructor.
      get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_print_form_ecus.

    METHODS:
      "Form in Parking List (Form Hải quan)
      get_form_parking_list_hq
        IMPORTING
          i_ecus_header TYPE zcs_ecus_header
          i_items       TYPE tt_items
        EXPORTING
          attachment    TYPE ty_attachment,

      "Form in Parking List (Form Khách hàng)
      get_form_parking_list_kh
        EXPORTING
          attachment TYPE ty_attachment,

      "Form in Commercial Invoice (Form Hải quan)
      get_form_commercial_invoice_hq
        EXPORTING
          attachment TYPE ty_attachment,

      "Form in Commercial Invoice (Form khách hàng)
      get_form_commercial_invoice_kh
        EXPORTING
          attachment TYPE ty_attachment,

      "Form in Sales Contract (Form excel)
      get_form_sales_contract,

      "Form in SI
      get_form_si
        EXPORTING
          attachment TYPE ty_attachment,

      "Form in VGM
      get_form_vgm
        EXPORTING
          attachment TYPE ty_attachment.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_PRINT_FORM_ECUS IMPLEMENTATION.


  METHOD get_instance.
    mo_instance = ro_instance = COND #( WHEN mo_instance IS BOUND
                                                   THEN mo_instance
                                                   ELSE NEW #( ) ).
  ENDMETHOD.


  METHOD get_form_commercial_invoice_hq.
    "Test
*        Data: lr_test tYPE tt_ranges
  ENDMETHOD.


  METHOD get_form_commercial_invoice_kh.

  ENDMETHOD.


  METHOD get_form_parking_list_hq.
    CHECK 1 = 2.

    TYPES: BEGIN OF ty_header,
             shipperexportername    TYPE string,
             shipperexporteraddress TYPE string,
             buyerimportername      TYPE string,
             buyerimporteraddress   TYPE string,
             portofshipment         TYPE string,
             portofdischarge        TYPE string,
             vesselsnames           TYPE string,
             trunkvessel            TYPE string,
             estimatedofdelivery    TYPE d,
           END OF ty_header.

    TYPES: BEGIN OF ty_total,
             totalqpcs    TYPE decfloat34,
             totalctns    TYPE decfloat34,
             totalplpcs   TYPE decfloat34,
             totalgweight TYPE decfloat34,
             totalnweight TYPE decfloat34,
           END OF ty_total.

    TYPES: BEGIN OF ty_item,
             stt                 TYPE i,
             salesorder          TYPE string,
             billingdocumentitem TYPE string,
             outbounddelivery    TYPE string,
             commoditysku        TYPE string,
             billingquantity     TYPE decfloat34,
             quantityctns        TYPE decfloat34,
             pallet              TYPE decfloat34,
             gweight             TYPE decfloat34,
             nweight             TYPE decfloat34,
             containerno         TYPE string,
           END OF ty_item.

    TYPES ty_t_item TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    TYPES: BEGIN OF ty_payload,
             header TYPE ty_header,
             total  TYPE ty_total,
             items  TYPE ty_t_item,
           END OF ty_payload.

    "Demo Data Test
    DATA(ls_payload) = VALUE ty_payload(
  header = VALUE #(
                    shipperexportername    = 'CASABLANCA JSC'
                    shipperexporteraddress = 'HCMC, Vietnam'
                    buyerimportername      = 'ABC IMPORT LTD'
                    buyerimporteraddress   = 'Tokyo, Japan'
                    portofshipment         = 'CAT LAI'
                    portofdischarge        = 'YOKOHAMA'
                    vesselsnames           = 'EVER GREEN'
                    trunkvessel            = 'TRUNK-01'
                    estimatedofdelivery    = '20260228' )
  total  = VALUE #(
                    totalqpcs              = '1500'
                    totalctns              = '1481'
                    totalplpcs             = '25'
                    totalgweight           = '12345.67'
                    totalnweight           = '12000.11' )
  items  = VALUE #(
                   ( stt          = 1        salesorder      = 'SO001' billingdocumentitem = '10'   outbounddelivery = '800001'
                     commoditysku = 'SKU-01' billingquantity = '100'   quantityctns        = '98'
                     pallet       = '2'      gweight         = '900'   nweight             = '870'  containerno      = 'CONT001' )
                   ( stt          = 2        salesorder      = 'SO002' billingdocumentitem = '20'   outbounddelivery = '800002'
                     commoditysku = 'SKU-02' billingquantity = '200'   quantityctns        = '196'
                     pallet       = '4'      gweight         = '1800'  nweight             = '1740' containerno      = 'CONT002' ) ) ).


    DATA: lv_template_xstring TYPE xstring.

    SELECT SINGLE file_content FROM zcore_tb_temppdf
        WHERE id = 'PackingListHQ'
        INTO @DATA(lv_b64).

    lv_template_xstring = lv_b64.

    DATA(lo_engine) = NEW zcl_xlsx_named_template_engine(
      iv_template_xlsx = lv_template_xstring ).

    DATA(lr_payload) = REF #( ls_payload ).

    DATA(lv_result_xlsx) = lo_engine->render(
      ir_data = lr_payload ).

    attachment-filecontent = lv_result_xlsx.

  ENDMETHOD.


  METHOD get_form_parking_list_kh.

  ENDMETHOD.


  METHOD get_form_sales_contract.

  ENDMETHOD.


  METHOD get_form_si.

  ENDMETHOD.


  METHOD get_form_vgm.

  ENDMETHOD.
ENDCLASS.
