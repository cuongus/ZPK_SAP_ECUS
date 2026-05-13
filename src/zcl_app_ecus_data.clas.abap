CLASS zcl_app_ecus_data DEFINITION
  PUBLIC
  INHERITING FROM cx_rap_query_provider
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.

    TYPES: BEGIN OF ty_range_option,
             sign   TYPE c LENGTH 1,
             option TYPE c LENGTH 2,
             low    TYPE string,
             high   TYPE string,
           END OF ty_range_option.

    TYPES tt_ranges TYPE STANDARD TABLE OF ty_range_option WITH EMPTY KEY.

    TYPES: BEGIN OF ty_business_partner,
             businesspartner TYPE i_businesspartner-businesspartner,
             name            TYPE string,
             adress          TYPE string,
           END OF ty_business_partner.

    TYPES: BEGIN OF ty_prodnodetext,
             product           TYPE i_produnivhierarchynodebasic-product,
             parentnode        TYPE i_produnivhierarchynodebasic-parentnode,
             hierarchynodetext TYPE i_hierruntimerprstnnodetext-hierarchynodetext,
           END OF ty_prodnodetext.

    TYPES: BEGIN OF ty_billingtitemprcgelmnt,
             billingdocument     TYPE i_billingdocumentitemprcgelmnt-billingdocument,
             billingdocumentitem TYPE i_billingdocumentitemprcgelmnt-billingdocumentitem,
             conditiontype       TYPE i_billingdocumentitemprcgelmnt-conditiontype,
             conditionamount     TYPE i_billingdocumentitemprcgelmnt-conditionamount,
             transactioncurrency TYPE i_billingdocumentitemprcgelmnt-transactioncurrency,
           END OF ty_billingtitemprcgelmnt.

    TYPES: BEGIN OF ty_in_container,
             outbounddelivery     TYPE i_outbounddeliveryitem-outbounddelivery,
             outbounddeliveryitem TYPE i_outbounddeliveryitem-outbounddeliveryitem,
             so_thung             TYPE ztb_in_container-so_thung,
             so_kg                TYPE ztb_in_container-so_kg,
             container            TYPE ztb_in_container-container,
             so_chi               TYPE ztb_in_container-so_chi,
             quantity             TYPE ztb_in_container-quantity,
             kt_thung             TYPE ztb_in_container-kt_thung,
           END OF ty_in_container.

    TYPES: BEGIN OF ty_clfnobjectcharcvalue,
             materialnumber TYPE zcs_ecus_items-materialnumber,
             charcvalue     TYPE i_clfnobjectcharcvalue-charcvalue,
           END OF ty_clfnobjectcharcvalue.

    TYPES:
      tt_businesspartner_cache TYPE HASHED TABLE OF ty_business_partner
        WITH UNIQUE KEY businesspartner,

      tt_log_ecusheader_cache  TYPE HASHED TABLE OF zaecusheader
        WITH UNIQUE KEY billingdocument,

      tt_log_ecusitems_cache   TYPE HASHED TABLE OF zaecusitems
        WITH UNIQUE KEY billingdocument billingdocumentitem,

      tt_prodnodetext_cache    TYPE HASHED TABLE OF ty_prodnodetext
        WITH UNIQUE KEY product,

      tt_billingprice_cache    TYPE HASHED TABLE OF ty_billingtitemprcgelmnt
        WITH UNIQUE KEY billingdocument billingdocumentitem,

      tt_in_container_cache    TYPE HASHED TABLE OF ty_in_container
        WITH UNIQUE KEY outbounddelivery outbounddeliveryitem,

      tt_clfnobject_cache      TYPE HASHED TABLE OF ty_clfnobjectcharcvalue
        WITH UNIQUE KEY materialnumber.

    TYPES:
      tt_billingheadertext TYPE TABLE FOR READ RESULT i_billingdocumenttp\_text,
      tt_billingitemtext   TYPE TABLE FOR READ RESULT i_billingdocumentitemtp\_itemtext,
      tt_odheadertext      TYPE TABLE FOR READ RESULT i_outbounddeliverytp\_text,
      gty_ecus_header      TYPE STANDARD TABLE OF zcs_ecus_header WITH EMPTY KEY,
      gty_ecus_items       TYPE STANDARD TABLE OF zcs_ecus_items WITH EMPTY KEY.

    TYPES: BEGIN OF ty_source_line,
             billingdocument      TYPE i_billingdocument-billingdocument,
             billingdocumentitem  TYPE i_billingdocumentitem-billingdocumentitem,
             billingdocumentdate  TYPE i_billingdocument-billingdocumentdate,
             salesorganization    TYPE i_billingdocument-salesorganization,
             distributionchannel  TYPE i_billingdocument-distributionchannel,
             soldtoparty          TYPE i_billingdocument-soldtoparty,
             incoterms            TYPE i_billingdocument-incotermsclassification,
             portofshipment       TYPE i_billingdocument-incotermslocation1,
             portofdischarge      TYPE i_billingdocument-incotermslocation2,
             billoflading         TYPE i_outbounddelivery-billoflading,
             searchterm1          TYPE i_businesspartner-searchterm1,
             companycode          TYPE i_billingdocumentitem-companycode,
             pono                 TYPE i_salesdocumentitem-purchaseorderbycustomer,
             customeritemnostyle  TYPE i_billingdocumentitem-billingdocumentitemtext,
             salesdocument        TYPE i_billingdocumentitem-salesdocument,
             salesdocumentitem    TYPE i_billingdocumentitem-salesdocumentitem,
             outbounddelivery     TYPE i_outbounddeliveryitem-outbounddelivery,
             outbounddeliveryitem TYPE i_outbounddeliveryitem-outbounddeliveryitem,
             materialnumber       TYPE i_billingdocumentitem-product,
             materialdescription  TYPE i_billingdocumentitem-billingdocumentitemtext,
             billingquantity      TYPE i_billingdocumentitem-billingquantity,
             baseunitofmeasure    TYPE i_billingdocumentitem-baseunit,
           END OF ty_source_line.

    TYPES tt_source_line TYPE STANDARD TABLE OF ty_source_line WITH EMPTY KEY.

    CLASS-DATA mo_instance TYPE REF TO zcl_app_ecus_data.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_app_ecus_data.

    METHODS get_data_app_ecus
      IMPORTING
        ir_billingdocument      TYPE tt_ranges
        ir_billingdocumentdate  TYPE tt_ranges OPTIONAL
        ir_shipperexporter      TYPE tt_ranges OPTIONAL
        ir_buyerimporter        TYPE tt_ranges OPTIONAL
        ir_containerno          TYPE tt_ranges OPTIONAL
        ir_containersealno      TYPE tt_ranges OPTIONAL
        ir_salesdocument        TYPE tt_ranges OPTIONAL
        ir_salesdocumentitem    TYPE tt_ranges OPTIONAL
        ir_outbounddelivery     TYPE tt_ranges OPTIONAL
        ir_outbounddeliveryitem TYPE tt_ranges OPTIONAL
      EXPORTING
        et_ecus_header          TYPE gty_ecus_header
        et_ecus_items           TYPE gty_ecus_items.

  PRIVATE SECTION.

    DATA mt_businesspartner      TYPE tt_businesspartner_cache.
    DATA mt_log_ecusheader       TYPE tt_log_ecusheader_cache.
    DATA mt_log_ecusitems        TYPE tt_log_ecusitems_cache.
    DATA mt_prodnodetext         TYPE tt_prodnodetext_cache.
    DATA mt_billingprice         TYPE tt_billingprice_cache.
    DATA mt_in_container         TYPE tt_in_container_cache.
    DATA mt_clfnobjectcharcvalue TYPE tt_clfnobject_cache.

    METHODS clear_cache.

    METHODS get_provided_ranges
      IMPORTING
        io_request              TYPE REF TO if_rap_query_request
      EXPORTING
        er_billingdocument      TYPE tt_ranges
        er_billingdocumentdate  TYPE tt_ranges
        er_shipperexporter      TYPE tt_ranges
        er_buyerimporter        TYPE tt_ranges
        er_containerno          TYPE tt_ranges
        er_containersealno      TYPE tt_ranges
        er_salesdocument        TYPE tt_ranges
        er_salesdocumentitem    TYPE tt_ranges
        er_outbounddelivery     TYPE tt_ranges
        er_outbounddeliveryitem TYPE tt_ranges.

    METHODS fill_header
      IMPORTING
        is_header            TYPE ty_source_line
        it_billingheadertext TYPE tt_billingheadertext
      EXPORTING
        es_header            TYPE zcs_ecus_header.

    METHODS fill_items
      IMPORTING
        is_item            TYPE ty_source_line
        it_odheadertext    TYPE tt_odheadertext
        it_billingitemtext TYPE tt_billingitemtext
      EXPORTING
        es_item            TYPE zcs_ecus_items.

    METHODS get_businesspartner
      IMPORTING
        i_businesspartner TYPE i_businesspartner-businesspartner
      EXPORTING
        e_businesspartner TYPE ty_business_partner.
ENDCLASS.



CLASS zcl_app_ecus_data IMPLEMENTATION.


  METHOD clear_cache.
    CLEAR: mt_businesspartner,
           mt_log_ecusheader,
           mt_log_ecusitems,
           mt_prodnodetext,
           mt_billingprice,
           mt_in_container,
           mt_clfnobjectcharcvalue.
  ENDMETHOD.


  METHOD get_instance.
    mo_instance = COND #( WHEN mo_instance IS BOUND THEN mo_instance ELSE NEW #( ) ).
    ro_instance = mo_instance.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.

*/-- Variable --*/
    DATA: lt_ecus_header TYPE gty_ecus_header,
          lt_ecus_items  TYPE gty_ecus_items.

    DATA(lv_entity_id) = io_request->get_entity_id( ).
    DATA(lo_paging)    = io_request->get_paging( ).

*/ ------- */
    TRY.

        "Get Filters Ranges
        get_provided_ranges(
          EXPORTING
            io_request              = io_request
          IMPORTING
            er_billingdocument      = DATA(ir_billingdocument)
            er_billingdocumentdate  = DATA(ir_billingdocumentdate)
            er_shipperexporter      = DATA(ir_shipperexporter)
            er_buyerimporter        = DATA(ir_buyerimporter)
            er_containerno          = DATA(ir_containerno)
            er_containersealno      = DATA(ir_containersealno)
            er_salesdocument        = DATA(ir_salesdocument)
            er_salesdocumentitem    = DATA(ir_salesdocumentitem)
            er_outbounddelivery     = DATA(ir_outbounddelivery)
            er_outbounddeliveryitem = DATA(ir_outbounddeliveryitem)
        ).

        LOOP AT ir_billingdocument ASSIGNING FIELD-SYMBOL(<fs_range>).
          IF <fs_range>-low IS NOT INITIAL.
            <fs_range>-low = |{ <fs_range>-low ALPHA = IN WIDTH = 10 }|.
          ENDIF.

          IF <fs_range>-high IS NOT INITIAL.
            <fs_range>-high = |{ <fs_range>-high ALPHA = IN WIDTH = 10 }|.
          ENDIF.
        ENDLOOP.

        "Get data for App
        get_data_app_ecus(
          EXPORTING
            ir_billingdocument      = ir_billingdocument
            ir_billingdocumentdate  = ir_billingdocumentdate
            ir_shipperexporter      = ir_shipperexporter
            ir_buyerimporter        = ir_buyerimporter
            ir_containerno          = ir_containerno
            ir_containersealno      = ir_containersealno
            ir_salesdocument        = ir_salesdocument
            ir_salesdocumentitem    = ir_salesdocumentitem
            ir_outbounddelivery     = ir_outbounddelivery
            ir_outbounddeliveryitem = ir_outbounddeliveryitem
          IMPORTING
            et_ecus_header          = lt_ecus_header
            et_ecus_items           = lt_ecus_items
        ).

        "Sort Dynamic Data
        DATA(lt_sort_elements) = io_request->get_sort_elements( ).
        DATA lt_otab TYPE abap_sortorder_tab .

        IF lt_sort_elements IS NOT INITIAL.
          LOOP AT lt_sort_elements INTO DATA(ls_sort_elements).
            APPEND VALUE #(
                name       = ls_sort_elements-element_name
                descending = ls_sort_elements-descending
*                astext
            ) TO lt_otab.
          ENDLOOP.
        ENDIF.

        "=== An Other Process ================================================

        "=== Paging =======================================================
        DATA(lv_page_size) = lo_paging->get_page_size( ).
        DATA(lv_offset)    = lo_paging->get_offset( ).

        IF lv_page_size < 0.
          lv_page_size = 50.
        ENDIF.

        CASE lv_entity_id.
          WHEN 'ZCS_ECUS_HEADER' OR 'ECUSHEADER'. ""---EInvoice Headers

            IF lt_otab IS NOT INITIAL.
              SORT lt_ecus_header BY (lt_otab).
            ENDIF.

            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lines( lt_ecus_header ) ).
            ENDIF.

            IF io_request->is_data_requested( ).
              DATA: lv_from_h TYPE i,
                    lv_to_h   TYPE i.

              lv_from_h = lv_offset + 1.

              IF lv_page_size = if_rap_query_paging=>page_size_unlimited.
                lv_to_h = lines( lt_ecus_header ).
              ELSE.
                lv_to_h = lv_offset + lv_page_size.
                IF lv_to_h > lines( lt_ecus_header ).
                  lv_to_h = lines( lt_ecus_header ).
                ENDIF.
              ENDIF.

              DATA(lt_header_page) = VALUE gty_ecus_header(
                FOR idx = lv_from_h WHILE idx <= lv_to_h
                ( lt_ecus_header[ idx ] )
              ).

              io_response->set_data( lt_header_page ).
            ENDIF.

          WHEN 'ZCS_ECUS_ITEMS' OR 'ECUSITEMS'. ""---EInvoice Items
            IF io_request->is_total_numb_of_rec_requested( ).
              io_response->set_total_number_of_records( lines( lt_ecus_items ) ).
            ENDIF.

            IF io_request->is_data_requested( ).
              DATA: lv_from_i    TYPE i,
                    lv_to_i      TYPE i,
                    lt_item_page TYPE gty_ecus_items.

              lv_from_i = lv_offset + 1.

              IF lv_page_size = if_rap_query_paging=>page_size_unlimited.
                lv_to_i = lines( lt_ecus_items ).
              ELSE.
                lv_to_i = lv_offset + lv_page_size.
                IF lv_to_i > lines( lt_ecus_items ).
                  lv_to_i = lines( lt_ecus_items ).
                ENDIF.
              ENDIF.

              IF lv_from_i <= lv_to_i AND lv_from_i > 0.
                lt_item_page = VALUE gty_ecus_items(
                  FOR idx = lv_from_i WHILE idx <= lv_to_i
                  ( lt_ecus_items[ idx ] )
                ).
              ENDIF.

              io_response->set_data( lt_item_page ).
            ENDIF.
        ENDCASE.

      CATCH cx_root INTO DATA(exception).

        IF cl_message_helper=>get_latest_t100_exception( exception ) IS BOUND.
          " Đã là T100 rồi → ném lại nguyên trạng, KHÔNG wrap
          RAISE EXCEPTION exception.
        ELSE.
          " Không phải T100 → wrap về 1 T100 của bạn
          RAISE EXCEPTION TYPE zcl_app_ecus_data
            EXPORTING
              textid = VALUE scx_t100key(
                        msgid = 'ZAPPECUS' msgno = '999'
                        attr1 = exception->get_text( ) ).
        ENDIF.

    ENDTRY.
  ENDMETHOD.


  METHOD get_provided_ranges.
    "*======================================================================
    "* Helper: đọc filter ranges từ request
    "*======================================================================

    TRY.
        DATA(lt_ranges) = io_request->get_filter( )->get_as_ranges( ).

        FIELD-SYMBOLS <rt_target> TYPE tt_ranges.

        LOOP AT lt_ranges REFERENCE INTO DATA(lr_range).

          "Xác định bảng range đích

          CASE lr_range->name.

            WHEN 'BILLINGDOCUMENT'.
              ASSIGN er_billingdocument TO <rt_target>.
            WHEN 'BILLINGDOCUMENTDATE'.
              ASSIGN er_billingdocumentdate TO <rt_target>.
            WHEN 'SHIPPEREXPORTERNAME'.
              ASSIGN er_shipperexporter TO <rt_target>.
            WHEN 'BUYERIMPORTERNAME'.
              ASSIGN er_buyerimporter TO <rt_target>.
            WHEN 'CONTAINERNO'.
              ASSIGN er_containerno TO <rt_target>.
            WHEN 'CONTAINERSEALNO'.
              ASSIGN er_containersealno TO <rt_target>.
            WHEN 'SALESDOCUMENT'.
              ASSIGN er_salesdocument TO <rt_target>.
            WHEN 'SALESDOCUMENTITEM'.
              ASSIGN er_salesdocumentitem TO <rt_target>.
            WHEN 'OUTBOUNDDELIVERY'.
              ASSIGN er_outbounddelivery TO <rt_target>.
            WHEN 'OUTBOUNDDELIVERYITEM'.
              ASSIGN er_outbounddeliveryitem TO <rt_target>.
            WHEN OTHERS.
          ENDCASE.

          "Nếu không map được thì bỏ qua
          IF <rt_target> IS NOT ASSIGNED.
            CONTINUE.
          ENDIF.

          "Đổ từng dòng range sang ty_ranges
          LOOP AT lr_range->range REFERENCE INTO DATA(lr_entry).
            INSERT VALUE ty_range_option(
                     sign   = lr_entry->sign
                     option = lr_entry->option
                     low    = CONV #( lr_entry->low )
                     high   = CONV #( lr_entry->high ) )
              INTO TABLE <rt_target>.
          ENDLOOP.

        ENDLOOP.

      CATCH cx_rap_query_filter_no_range INTO DATA(lx_prev).
        "tuỳ bạn có log thêm hay không
    ENDTRY.
  ENDMETHOD.


  METHOD get_data_app_ecus.

    clear_cache( ).

    SELECT
      a~billingdocument,
      b~billingdocumentitem,
      a~billingdocumentdate,
      a~salesorganization,
      a~distributionchannel,
      a~soldtoparty,
      a~incotermsclassification AS incoterms,
      a~incotermslocation1      AS portofshipment,
      a~incotermslocation2      AS portofdischarge,
      e~billoflading,
      f~searchterm1,
      b~companycode,
      c~purchaseorderbycustomer AS pono,
      b~billingdocumentitemtext AS customeritemnostyle,
      b~salesdocument,
      b~salesdocumentitem,
      CASE WHEN b~referencesddocumentcategory = 'J'
           THEN b~referencesddocument ELSE NULL END AS outbounddelivery,
      CASE WHEN b~referencesddocumentcategory = 'J'
           THEN b~referencesddocumentitem ELSE NULL END AS outbounddeliveryitem,
      b~product                 AS materialnumber,
      b~billingdocumentitemtext AS materialdescription,
      b~billingquantity,
      b~baseunit                    AS baseunitofmeasure
      FROM i_billingdocumentitem    AS b
      INNER JOIN i_billingdocument  AS a
        ON a~billingdocument = b~billingdocument
      INNER JOIN i_salesdocumentitem AS c
        ON c~salesdocument     = b~salesdocument
       AND c~salesdocumentitem = b~salesdocumentitem
      LEFT OUTER JOIN i_outbounddelivery AS e
        ON e~outbounddelivery = b~referencesddocument
      LEFT OUTER JOIN i_businesspartner AS f
        ON f~businesspartner = a~soldtoparty
      WHERE a~billingdocument          IN @ir_billingdocument
        AND a~billingdocumentdate      IN @ir_billingdocumentdate
        AND b~salesdocument            IN @ir_salesdocument
        AND b~salesdocumentitem        IN @ir_salesdocumentitem
        AND b~referencesddocument      IN @ir_outbounddelivery
        AND b~referencesddocumentitem  IN @ir_outbounddeliveryitem
        AND a~billingdocumenttype      = 'F8'
        AND a~billingdocumentiscancelled = ''
        AND a~cancelledbillingdocument   = ''
        AND b~billingquantity <> 0
      INTO TABLE @DATA(lt_billingdocument).

    IF lt_billingdocument IS INITIAL.
      CLEAR: et_ecus_header, et_ecus_items.
      RETURN.
    ENDIF.

    SORT lt_billingdocument BY billingdocument billingdocumentitem.

    DATA: lt_billingkeys     TYPE SORTED TABLE OF i_billingdocumenttp WITH UNIQUE KEY billingdocument,
          lt_billingitemkeys TYPE SORTED TABLE OF i_billingdocumentitemtp WITH UNIQUE KEY billingdocument billingdocumentitem,
          lt_odkeys          TYPE SORTED TABLE OF i_outbounddeliverytp WITH UNIQUE KEY outbounddelivery,
          lt_container_keys  TYPE SORTED TABLE OF ztb_in_container-outbound_delivery WITH UNIQUE KEY table_line.

    LOOP AT lt_billingdocument INTO DATA(ls_doc).
      INSERT VALUE #( billingdocument = ls_doc-billingdocument ) INTO TABLE lt_billingkeys.
      INSERT VALUE #( billingdocument     = ls_doc-billingdocument
                      billingdocumentitem = ls_doc-billingdocumentitem
      ) INTO TABLE lt_billingitemkeys.
      IF ls_doc-outbounddelivery IS NOT INITIAL.
        INSERT VALUE #( outbounddelivery = ls_doc-outbounddelivery ) INTO TABLE lt_odkeys.
        INSERT CONV ztb_in_container-outbound_delivery( ls_doc-outbounddelivery ) INTO TABLE lt_container_keys.
      ENDIF.
    ENDLOOP.

    IF lt_billingdocument IS NOT INITIAL.
      SELECT * FROM zaecusheader
        FOR ALL ENTRIES IN @lt_billingdocument
        WHERE billingdocument = @lt_billingdocument-billingdocument
        INTO TABLE @DATA(lt_log_header_raw).

      mt_log_ecusheader = CORRESPONDING #( lt_log_header_raw ).

      SELECT * FROM zaecusitems
        FOR ALL ENTRIES IN @lt_billingdocument
        WHERE billingdocument = @lt_billingdocument-billingdocument
        INTO TABLE @DATA(lt_log_item_raw).
    ENDIF.

    mt_log_ecusitems = CORRESPONDING #( lt_log_item_raw ).

    SELECT
      FROM @lt_billingdocument AS x
      INNER JOIN i_clfnobjectcharcvalue AS a
        ON x~materialnumber = a~clfnobjectid
      INNER JOIN i_clfncharacteristic AS b
        ON a~charcinternalid = b~charcinternalid
      FIELDS
        x~materialnumber,
        a~charcvalue
      WHERE a~classtype       = '001'
        AND a~clfnobjecttable = 'MARA'
        AND b~characteristic  = 'Z_KICHTHUOC'
      INTO TABLE @DATA(lt_char_raw).

    SORT lt_char_raw BY materialnumber.
    DELETE ADJACENT DUPLICATES FROM lt_char_raw COMPARING materialnumber.

    mt_clfnobjectcharcvalue = CORRESPONDING #( lt_char_raw ).

    IF lt_billingdocument IS NOT INITIAL.
      SELECT
        a~product,
        a~parentnode,
        c~hierarchynodetext
        FROM i_produnivhierarchynodebasic AS a
        INNER JOIN i_hierruntimerprstnnodetext AS b
          ON b~hierarchynode = a~parentnode
        INNER JOIN i_hierruntimerprstnnodetext AS c
          ON c~hierarchynode = b~parentnode
        FOR ALL ENTRIES IN @lt_billingdocument
        WHERE a~produnivhierarchy = 'PH_SALES'
          AND b~runtimehierarchy  LIKE '%PH_SALES%'
          AND c~runtimehierarchy  LIKE '%PH_SALES%'
          AND c~language          = 'E'
          AND a~product           = @lt_billingdocument-materialnumber
        INTO TABLE @DATA(lt_prod_raw).

      mt_prodnodetext = CORRESPONDING #( lt_prod_raw ).
    ENDIF.

    IF lt_billingdocument IS NOT INITIAL.
      SELECT
        billingdocument,
        billingdocumentitem,
        conditiontype,
        conditionamount,
        transactioncurrency
        FROM i_billingdocumentitemprcgelmnt
        FOR ALL ENTRIES IN @lt_billingdocument
        WHERE billingdocument   = @lt_billingdocument-billingdocument
          AND conditiontype     = 'ZPR1'
        INTO TABLE @DATA(lt_price_raw).

      mt_billingprice = CORRESPONDING #( lt_price_raw ).
    ENDIF.

    IF lt_container_keys IS NOT INITIAL.
      SELECT
        outbound_delivery,
        outbound_delivery_item,
        container,
        so_chi,
        so_thung,
        so_kg,
        quantity,
        kt_thung
        FROM ztb_in_container
        FOR ALL ENTRIES IN @lt_container_keys
        WHERE outbound_delivery = @lt_container_keys-table_line
        INTO TABLE @DATA(lt_container_raw).

      LOOP AT lt_container_raw INTO DATA(ls_container_raw).
        INSERT VALUE ty_in_container(
          outbounddelivery     = ls_container_raw-outbound_delivery
          outbounddeliveryitem = ls_container_raw-outbound_delivery_item
          container            = ls_container_raw-container
          so_chi               = ls_container_raw-so_chi
          so_thung             = ls_container_raw-so_thung
          so_kg                = ls_container_raw-so_kg
          quantity             = ls_container_raw-quantity
          kt_thung             = ls_container_raw-kt_thung ) INTO TABLE mt_in_container.
      ENDLOOP.
    ENDIF.

    READ ENTITIES OF i_billingdocumenttp
      ENTITY billingdocument
      BY \_text
      ALL FIELDS WITH CORRESPONDING #( lt_billingkeys )
      RESULT DATA(lt_billingheadertext)

      ENTITY billingdocumentitem
      BY \_itemtext
      ALL FIELDS WITH CORRESPONDING #( lt_billingitemkeys )
      RESULT DATA(lt_billingitemtext)
      FAILED DATA(ls_bill_failed).

    SORT lt_billingheadertext BY billingdocument language longtextid.
    SORT lt_billingitemtext BY billingdocument billingdocumentitem language longtextid.

    READ ENTITIES OF i_outbounddeliverytp
      ENTITY outbounddelivery
      BY \_text
      ALL FIELDS WITH CORRESPONDING #( lt_odkeys )
      RESULT DATA(lt_odheadertext)
      FAILED DATA(ls_od_failed).

    SORT lt_odheadertext BY outbounddelivery language longtextid.

    DATA: lt_ecus_header TYPE gty_ecus_header,
          lt_ecus_items  TYPE gty_ecus_items.

    LOOP AT lt_billingdocument INTO DATA(ls_line)
      GROUP BY ( billingdocument = ls_line-billingdocument )
      ASCENDING REFERENCE INTO DATA(lr_group).

      DATA(lv_header_done) = abap_false.

      LOOP AT GROUP lr_group INTO DATA(ls_group_line).

        IF lv_header_done = abap_false.
          lv_header_done = abap_true.

          fill_header(
            EXPORTING
              is_header            = ls_group_line
              it_billingheadertext = lt_billingheadertext
            IMPORTING
              es_header            = DATA(ls_header) ).

          APPEND ls_header TO lt_ecus_header.
        ENDIF.

        fill_items(
          EXPORTING
            is_item            = ls_group_line
            it_odheadertext    = lt_odheadertext
            it_billingitemtext = lt_billingitemtext
          IMPORTING
            es_item            = DATA(ls_item) ).

        APPEND ls_item TO lt_ecus_items.
      ENDLOOP.
    ENDLOOP.

    et_ecus_header = lt_ecus_header.
    et_ecus_items  = lt_ecus_items.

  ENDMETHOD.


  METHOD fill_header.


    CLEAR es_header.

    es_header-billingdocument      = is_header-billingdocument.
    es_header-billingdocumentdate  = is_header-billingdocumentdate.
    es_header-incoterms            = is_header-incoterms.
    es_header-portofshipment       = is_header-portofshipment.
    es_header-portofdischarge      = is_header-portofdischarge.
*    es_header-billoflading         = is_header-billoflading.
    es_header-salesorganization    = is_header-salesorganization.
    es_header-distributionchannel  = is_header-distributionchannel.
    es_header-searchterm1          = is_header-searchterm1.

    CASE es_header-salesorganization.
      WHEN '6710'.
        es_header-shipperexportername    = 'CASLA JOINT STOCK COMPANY'.
        es_header-shipperexporteraddress = 'CHAU SON INDUSTRIAL ZONE, CHAU SON WARD, PHU LY CITY, HA NAM PROVINCE, VIETNAM'.

        es_header-shippervgm = 'CASLA JOINT STOCK COMPANY'.
        es_header-addressvgm = 'CHAU SON INDUSTRIAL ZONE, CHAU SON WARD, PHU LY CITY, HA NAM PROVINCE, VIETNAM'.
      WHEN '6720'.
        es_header-shipperexportername    = 'CASABLANCA JOINT STOCK COMPANY'.
        es_header-shipperexporteraddress = 'NON SAO INDUSTRIAL ZONE, TAN MOI, TAN DINH, BAC NINH PROVINCE, VIET NAM'.

        es_header-shippervgm = 'CASABLANCA JOINT STOCK COMPANY'.
        es_header-addressvgm = 'NON SAO INDUSTRIAL ZONE, TAN MOI, TAN DINH, BAC NINH PROVINCE, VIET NAM'.
    ENDCASE.

    get_businesspartner(
      EXPORTING
        i_businesspartner = is_header-soldtoparty
      IMPORTING
        e_businesspartner = DATA(ls_bp) ).

    es_header-buyerimportername    = ls_bp-name.
    es_header-buyerimporteraddress = ls_bp-adress.
    es_header-consigneename        = ls_bp-name.
    es_header-consigneeaddress     = ls_bp-adress.
    es_header-countryoforigin      = 'VIETNAM'.

    "Thay đổi logic - Date 05/05/2026
*    es_header-NotifyParty1 = ls_bp-name.

    "Thay đổi logic - Date 13/05/2026
    es_header-NotifyParty1 = ls_bp-name && ` <> ` && ls_bp-adress.

    READ TABLE mt_log_ecusheader INTO DATA(ls_log_header)
      WITH TABLE KEY billingdocument = es_header-billingdocument.
    IF sy-subrc = 0.
      es_header-declarationno = ls_log_header-declarationno.

      IF ls_log_header-NotifyParty1 IS NOT INITIAL.
        es_header-NotifyParty1 = ls_log_header-NotifyParty1.
      ENDIF.

      IF ls_log_header-notifyparty2 IS NOT INITIAL.
        es_header-notifyparty2 = ls_log_header-notifyparty2.
      ENDIF.

      IF ls_log_header-saillingonorabout IS NOT INITIAL.
        es_header-saillingonorabout   = ls_log_header-saillingonorabout.
        es_header-estimatedofdelivery = ls_log_header-saillingonorabout.
      ENDIF.

      IF ls_log_header-depositcontract IS NOT INITIAL.
        es_header-depositcontract = ls_log_header-depositcontract.
      ENDIF.

      IF ls_log_header-cylinderquantity IS NOT INITIAL.
        es_header-cylinderquantity = ls_log_header-cylinderquantity.
      ENDIF.

      IF ls_log_header-cylinderamount IS NOT INITIAL.
        es_header-cylinderamount = ls_log_header-cylinderamount.
      ENDIF.
      IF ls_log_header-termofpaymentcontract IS NOT INITIAL.
        es_header-termofpaymentcontract = ls_log_header-termofpaymentcontract.
      ENDIF.

      IF ls_log_header-finaldestination IS NOT INITIAL.
        es_header-finaldestination = ls_log_header-finaldestination.
      ENDIF.

      IF ls_log_header-estimatedofdelivery IS NOT INITIAL.
        es_header-estimatedofdelivery = ls_log_header-estimatedofdelivery.
      ENDIF.
      IF ls_log_header-timeofdelivery IS NOT INITIAL.
        es_header-timeofdelivery = ls_log_header-timeofdelivery.
      ENDIF.

      IF ls_log_header-partialshipment IS NOT INITIAL.
        es_header-partialshipment = ls_log_header-partialshipment.
      ENDIF.

      IF ls_log_header-billoflading IS NOT INITIAL.
        es_header-billoflading = ls_log_header-billoflading.
      ENDIF.

      IF ls_log_header-commercialinvoice IS NOT INITIAL.
        es_header-commercialinvoice = ls_log_header-commercialinvoice.
      ENDIF.

      IF ls_log_header-remarks IS NOT INITIAL.
        es_header-remarks = ls_log_header-remarks.
      ENDIF.

    ENDIF.

    LOOP AT VALUE stringtab( ( `Z035` ) ( `Z044` ) ( `Z036` ) ( `Z042` ) ( `Z038` ) ( `Z039` ) ( `Z037` ) ( `Z043` ) ( `Z013` ) ( `Z014` ) )
      INTO DATA(lv_textid).

      READ TABLE it_billingheadertext INTO DATA(ls_text)
        WITH KEY billingdocument = es_header-billingdocument
                 language        = 'E'
                 longtextid      = lv_textid
        BINARY SEARCH.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN ls_text-longtext WITH space.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN ls_text-longtext WITH space. "namnh214 thêm
      CASE lv_textid.
*        WHEN 'Z035'. es_header-notifyparty1  = ls_text-longtext.   "Thay đổi logic ko lấy từ longtext - Date 05/05/2026 - AK3K905104
        WHEN 'Z044'. es_header-shipto        = ls_text-longtext.
        WHEN 'Z036'. es_header-thethirtparty = ls_text-longtext.
*        WHEN 'Z042'. es_header-remarks       = ls_text-longtext. "Thay đổi logic ko lấy từ longtext
        WHEN 'Z038'. es_header-vesselsnames  = ls_text-longtext.
        WHEN 'Z037'. es_header-carrier       = ls_text-longtext.
        WHEN 'Z043'. es_header-termofpayment = ls_text-longtext.
        WHEN 'Z039'. es_header-trunkvessel   = ls_text-longtext.
        WHEN 'Z013'. es_header-solc          = ls_text-longtext.
        WHEN 'Z014'. es_header-ngaymolc      = ls_text-longtext.
      ENDCASE.
    ENDLOOP.

*    if es_header-solc is NOT INITIAL.
*    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN es_header-solc WITH space.
*    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN es_header-solc WITH space.
*    CONDENSE es_header-solc NO-GAPS.
*    endIF.

    es_header-termsofdelivery = |{ es_header-remarks } { es_header-incoterms } { es_header-estimatedofdelivery }|.
    es_header-portofshipment  = |{ es_header-portofshipment } { es_header-estimatedofdelivery }|.
    es_header-portofshipment2  = |{ is_header-portofshipment }, VIETNAM|.

    CASE es_header-salesorganization.
      WHEN '6710'.
*        es_header-commercialinvoice = |CL&{ es_header-searchterm1 }/{ es_header-billingdocument }|.
      WHEN '6720'.
*        es_header-commercialinvoice = |CA&{ es_header-searchterm1 }/{ es_header-billingdocument }|.
    ENDCASE.

  ENDMETHOD.


  METHOD fill_items.

    CLEAR es_item.

    es_item-billingdocument      = is_item-billingdocument.
    es_item-billingdocumentitem  = is_item-billingdocumentitem.
    es_item-pono                 = is_item-pono.
    es_item-customeritemnostyle  = is_item-customeritemnostyle.
    es_item-cinostylenochange    = is_item-customeritemnostyle.
    es_item-salesdocument        = is_item-salesdocument.
    es_item-salesdocumentitem    = is_item-salesdocumentitem.
    es_item-outbounddelivery     = is_item-outbounddelivery.
    es_item-outbounddeliveryitem = is_item-outbounddeliveryitem.
    es_item-materialnumber       = is_item-materialnumber.
    es_item-materialdescription  = is_item-materialdescription.
    es_item-billingquantity      = is_item-billingquantity.
    es_item-baseunitofmeasure    = is_item-baseunitofmeasure.

    READ TABLE mt_prodnodetext INTO DATA(ls_prod)
      WITH TABLE KEY product = es_item-materialnumber.
    IF sy-subrc = 0.
      es_item-ph_sales2           = ls_prod-hierarchynodetext.
      es_item-commoditynochange   = ls_prod-hierarchynodetext && ` SHOPPING BAG`.
    ENDIF.

    READ TABLE mt_log_ecusitems INTO DATA(ls_log_item)
      WITH TABLE KEY billingdocument = es_item-billingdocument
                     billingdocumentitem = es_item-billingdocumentitem.
    IF sy-subrc = 0.

      IF ls_log_item-customerpo IS NOT INITIAL.
        es_item-customerpo = ls_log_item-customerpo.
      ENDIF.

      IF ls_log_item-customeritemnostyle IS NOT INITIAL.
        es_item-customeritemnostyle = ls_log_item-customeritemnostyle.
      ENDIF.

      IF ls_log_item-commoditysku IS NOT INITIAL.
        es_item-commoditysku = ls_log_item-commoditysku.
      ENDIF.

      IF ls_log_item-hscode IS NOT INITIAL.
        es_item-hscode = ls_log_item-hscode.
      ENDIF.

      IF ls_log_item-lotno IS NOT INITIAL.
        es_item-lotno = ls_log_item-lotno.
      ENDIF.

      IF ls_log_item-pallet IS NOT INITIAL.
        es_item-pallet = ls_log_item-pallet.
      ENDIF.

      IF ls_log_item-sortitempackinglist IS NOT INITIAL.
        es_item-sortitempackinglist = ls_log_item-sortitempackinglist.
      ENDIF.

    ENDIF.

    LOOP AT VALUE stringtab( ( `Z006` ) ( `Z029` ) ( `Z034` ) ( `Z033` ) ( `Z045` ) )
      INTO DATA(lv_textid).

      READ TABLE it_odheadertext INTO DATA(ls_od_text)
        WITH KEY outbounddelivery = es_item-outbounddelivery
                 language         = 'E'
                 longtextid       = lv_textid
        BINARY SEARCH.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      CASE lv_textid.
        WHEN 'Z006'.
          es_item-containerno      = ls_od_text-longtext.
        WHEN 'Z029'.
          es_item-containersealno  = ls_od_text-longtext.
        WHEN 'Z034'.
          es_item-typeptvt         = ls_od_text-longtext.
        WHEN 'Z033'.
          es_item-quantityptvt     = ls_od_text-longtext.
        WHEN 'Z045'.
          TRY.
              es_item-TareWeight   = ls_od_text-LongText.
            CATCH cx_root.
          ENDTRY.
      ENDCASE.
    ENDLOOP.
    IF es_item-typeptvt IS INITIAL AND  es_item-quantityptvt IS INITIAL.
      es_item-typexquanptvt = ''.
    ELSE.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN es_item-quantityptvt WITH space.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN es_item-quantityptvt WITH space.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN es_item-typeptvt WITH space.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN es_item-typeptvt WITH space.
      es_item-typexquanptvt =  |{ es_item-quantityptvt } x { es_item-typeptvt } CONTAINERS|.
    ENDIF.
    READ TABLE mt_in_container INTO DATA(ls_container)
      WITH TABLE KEY outbounddelivery     = es_item-outbounddelivery
                     outbounddeliveryitem = es_item-outbounddeliveryitem.
    IF sy-subrc = 0.
      es_item-numberofboxes = ls_container-so_thung.
      es_item-gweight       = ls_container-so_thung * ls_container-so_kg.
      es_item-quantityctns  = ls_container-so_thung.
      es_item-cartonsize    = ls_container-kt_thung.
    ENDIF.

    READ TABLE mt_clfnobjectcharcvalue INTO DATA(ls_char)
      WITH TABLE KEY materialnumber = es_item-materialnumber.
    IF sy-subrc = 0.
      es_item-itemsize = ls_char-charcvalue.
    ENDIF.

    READ TABLE mt_billingprice INTO DATA(ls_price)
      WITH TABLE KEY billingdocument     = es_item-billingdocument
                     billingdocumentitem = es_item-billingdocumentitem.
    IF sy-subrc = 0.
      CASE ls_price-transactioncurrency.
        WHEN 'VND'.
          es_item-amount = ls_price-conditionamount * 100.
        WHEN 'USD'.
          es_item-amount = ls_price-conditionamount.
      ENDCASE.
    ENDIF.

    es_item-nweight = es_item-gweight - es_item-numberofboxes * 1 / 2.

    IF es_item-cartonsize IS NOT INITIAL.
      SPLIT es_item-cartonsize AT '*' INTO DATA(lv_n1) DATA(lv_n2) DATA(lv_n3).
    ENDIF.

    TRY.
        es_item-cbm = lv_n1 * lv_n2 * lv_n3 * es_item-numberofboxes / ipow( base = 10 exp = 9 ).
      CATCH cx_root.
    ENDTRY.

    IF es_item-billingquantity IS NOT INITIAL.
      es_item-unitpricefob = es_item-amount / es_item-billingquantity.
    ENDIF.

    es_item-typeofcontainers = |{ es_item-containerno }X{ es_item-typeptvt }CONTAINERS|.

    READ TABLE it_billingitemtext INTO DATA(ls_billingitemtext)
    WITH KEY billingdocument = es_item-billingdocument
             billingdocumentitem = es_item-billingdocumentitem
             language = 'E'
             longtextid = 'Y001' BINARY SEARCH.
    IF sy-subrc EQ 0.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN ls_billingitemtext-longtext WITH space.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN ls_billingitemtext-longtext WITH space.
      es_item-remarks = ls_billingitemtext-longtext.
    ENDIF.

  ENDMETHOD.


  METHOD get_businesspartner.

    READ TABLE mt_businesspartner INTO e_businesspartner
      WITH TABLE KEY businesspartner = i_businesspartner.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    e_businesspartner-businesspartner = i_businesspartner.

    SELECT SINGLE
      b~addressid,
      a~organizationbpname2,
      a~organizationbpname3,
      a~organizationbpname4
      FROM i_businesspartner AS a
      INNER JOIN i_buspartaddress AS b
        ON b~businesspartner = a~businesspartner
      WHERE a~businesspartner = @i_businesspartner
      INTO @DATA(ls_bp).

    IF sy-subrc = 0.
      e_businesspartner-name =
        |{ ls_bp-organizationbpname2 }{ ls_bp-organizationbpname3 }{ ls_bp-organizationbpname4 }|.

      SELECT SINGLE
        cityname,
        country,
        housenumber,
        street,
        streetprefixname1 AS street2,
        streetprefixname2 AS street3,
        streetsuffixname1 AS street4,
        streetsuffixname2 AS location
        FROM i_address_2 WITH PRIVILEGED ACCESS
        WHERE addressid = @ls_bp-addressid
        INTO @DATA(ls_address).

      IF sy-subrc = 0.
        e_businesspartner-adress =
          |{ ls_address-housenumber }{ ls_address-street }{ ls_address-street2 }{ ls_address-street3 }{ ls_address-street4 }|.

        IF ls_address-cityname IS NOT INITIAL.
          e_businesspartner-adress = |{ e_businesspartner-adress } { ls_address-cityname }|.
        ENDIF.

        SELECT SINGLE countryname
          FROM i_countrytext
          WHERE country = @ls_address-country
          INTO @DATA(lv_countryname).

        IF sy-subrc = 0.
          e_businesspartner-adress = |{ e_businesspartner-adress }, { lv_countryname }|.
        ENDIF.
      ENDIF.
    ENDIF.

    INSERT e_businesspartner INTO TABLE mt_businesspartner.

  ENDMETHOD.
ENDCLASS.
