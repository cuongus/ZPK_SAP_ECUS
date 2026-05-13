CLASS lhc_zrap_r_kb_mahq DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_data,
        companycode     TYPE string,
        ma_hai_quan     TYPE string,
        ten_ma_hai_quan TYPE string,
        hinh_thuc       TYPE string,
      END OF ty_data,
      tt_data TYPE STANDARD TABLE OF ty_data WITH EMPTY KEY.

    TYPES: failed_late   TYPE RESPONSE FOR FAILED LATE zrap_r_kb_mahq,
           reported_late TYPE RESPONSE FOR REPORTED LATE zrap_r_kb_mahq.

    METHODS validate_duplicate IMPORTING keys     TYPE ANY TABLE
                               EXPORTING e_exist  TYPE abap_boolean
                                         msg      TYPE REF TO if_abap_behv_message
                               CHANGING  failed   TYPE failed_late OPTIONAL
                                         reported TYPE reported_late.

    METHODS create_xlsx
      IMPORTING it_data        TYPE tt_data
      RETURNING VALUE(rv_xlsx) TYPE xstring.

    METHODS read_xlsx
      IMPORTING iv_xlsx        TYPE xstring
      RETURNING VALUE(rt_data) TYPE tt_data.

    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR khai_bao_ma_hq
        RESULT result.

    METHODS check_duplicate_save FOR VALIDATE ON SAVE
      IMPORTING keys FOR khai_bao_ma_hq~check_duplicate_save.

    METHODS downloadfile FOR MODIFY
      IMPORTING keys FOR ACTION khai_bao_ma_hq~downloadfile RESULT result.

    METHODS fileupload FOR MODIFY
      IMPORTING keys FOR ACTION khai_bao_ma_hq~fileupload RESULT result.

    METHODS effects_text FOR MODIFY
      IMPORTING keys FOR ACTION khai_bao_ma_hq~effects_text.

    METHODS get_companycode_name FOR DETERMINE ON MODIFY
      IMPORTING keys FOR khai_bao_ma_hq~get_companycode_name.

    METHODS check_modify FOR DETERMINE ON MODIFY
      IMPORTING keys FOR khai_bao_ma_hq~check_modify.
    METHODS precheck FOR MODIFY
      IMPORTING keys FOR ACTION khai_bao_ma_hq~precheck RESULT result.

ENDCLASS.

CLASS lhc_zrap_r_kb_mahq IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD check_duplicate_save.

    me->validate_duplicate(
      EXPORTING
        keys     = keys
      CHANGING
        failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD downloadfile.

    READ TABLE keys INDEX 1 INTO DATA(k).

    DATA(lt_data) = VALUE tt_data(
        ( companycode = '6710' ma_hai_quan = '10109900' ten_ma_hai_quan = 'Túi siêu thị' hinh_thuc = '1' )
        ( companycode = '6710' ma_hai_quan = '10109900' ten_ma_hai_quan = 'Túi siêu thị' hinh_thuc = '' )
        ( companycode = '6710' ma_hai_quan = '10109700' ten_ma_hai_quan = 'Túi siêu thị' hinh_thuc = '1' )
        ( companycode = '6720' ma_hai_quan = '10109900' ten_ma_hai_quan = 'Túi siêu thị' hinh_thuc = '1' )
    ).

    DATA(lv_xlsx) = me->create_xlsx( lt_data ).

    APPEND VALUE #(
        %cid   = k-%cid
        %param = VALUE #(
                          mimetype      = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                          filename      = 'Khaibao_MaHQ.xlsx'
                          filecontent   = lv_xlsx
                          fileextension = 'xlsx'
                          )
    ) TO result.
  ENDMETHOD.

  METHOD fileupload.
    DATA: lv_xlsx TYPE xstring.
    DATA: lt_kb_mahq TYPE TABLE FOR CREATE zrap_r_kb_mahq,
          ls_kb_mahq LIKE LINE OF lt_kb_mahq.

    READ TABLE keys INDEX 1 INTO DATA(k).

    lv_xlsx = k-%param-filecontent.

    DATA(lt_file) = me->read_xlsx( lv_xlsx ).

    LOOP AT lt_file INTO DATA(ls_file).
      ls_kb_mahq = VALUE #(
          companycode  = ls_file-companycode
*            companycodename
          mahaiquan    = ls_file-ma_hai_quan
          tenmahaiquan = ls_file-ten_ma_hai_quan
          hinhthuc     = ls_file-hinh_thuc
      ).

      APPEND ls_kb_mahq TO lt_kb_mahq.
      CLEAR: ls_kb_mahq.
    ENDLOOP.

    IF lt_kb_mahq IS NOT INITIAL.
      MODIFY ENTITIES OF zrap_r_kb_mahq IN LOCAL MODE
        ENTITY khai_bao_ma_hq
        CREATE AUTO FILL CID FIELDS (
*                          uuid
                           companycode
                           mahaiquan
                           tenmahaiquan
                           hinhthuc
                        ) WITH lt_kb_mahq
        MAPPED DATA(ls_mapped_cr)
        REPORTED DATA(ls_reported_cr)
        FAILED DATA(ls_failed_cr).
    ENDIF.
  ENDMETHOD.

  METHOD validate_duplicate.

    DATA: lt_keys TYPE TABLE FOR READ IMPORT zrap_r_kb_mahq.
    MOVE-CORRESPONDING keys TO lt_keys.

    READ ENTITIES OF zrap_r_kb_mahq IN LOCAL MODE
      ENTITY khai_bao_ma_hq
      FIELDS ( uuid companycode mahaiquan hinhthuc )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_new).

    IF lt_new IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_new INTO DATA(ls_new).
      IF ls_new-hinhthuc NE '' AND ls_new-hinhthuc NE '1'.
        "1) Chặn save
        APPEND VALUE #( %tky = ls_new-%tky ) TO failed-khai_bao_ma_hq.

        "2) Trả message + bôi đỏ field
        APPEND VALUE #(
          %tky     = ls_new-%tky
          %msg     = new_message(
                        id       = 'ZKBMAHQ'         "tạo message class của bạn
                        number   = '004'         "ví dụ: 'Đã tồn tại bản ghi TaxCode &1, TaxNo &2'
                        v1       = ls_new-companycode
                        v2       = ls_new-mahaiquan
                        v3       = ls_new-hinhthuc
                        severity = if_abap_behv_message=>severity-error )
          %element-companycode   = if_abap_behv=>mk-on
          %element-mahaiquan     = if_abap_behv=>mk-on
          %element-hinhthuc      = if_abap_behv=>mk-on
        ) TO reported-khai_bao_ma_hq.
      ENDIF.
    ENDLOOP.

    "Tìm bản ghi trùng trong bảng persistent (ngoại trừ chính nó khi update)
    TYPES: BEGIN OF ty_hit,
             uuid        TYPE sysuuid_x16,
             companycode TYPE zrap_kb_mahq-companycode,
             ma_hai_quan TYPE zrap_kb_mahq-ma_hai_quan,
             hinh_thuc   TYPE zrap_kb_mahq-hinh_thuc,
           END OF ty_hit.

    DATA lt_hit TYPE STANDARD TABLE OF ty_hit.

    "FOR ALL ENTRIES để dò theo từng cặp người dùng nhập
    SELECT uuid, companycode, ma_hai_quan, hinh_thuc FROM zrap_kb_mahq
    FOR ALL ENTRIES IN @lt_new
    WHERE companycode = @lt_new-companycode
      AND ma_hai_quan = @lt_new-mahaiquan
      AND hinh_thuc   = @lt_new-hinhthuc
      AND uuid        <> @lt_new-uuid           "loại chính nó khi update
    INTO CORRESPONDING FIELDS OF TABLE @lt_hit.

    IF lt_hit IS INITIAL.
      RETURN.
    ENDIF.

    "Map lại theo %tky để báo lỗi từng dòng
    LOOP AT lt_new ASSIGNING FIELD-SYMBOL(<ls_new>).

      READ TABLE lt_hit WITH KEY companycode         = <ls_new>-companycode
                                 ma_hai_quan         = <ls_new>-mahaiquan
                                 hinh_thuc           = <ls_new>-hinhthuc
           TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.

        "1) Chặn save
        APPEND VALUE #( %tky = <ls_new>-%tky ) TO failed-khai_bao_ma_hq.

        "2) Trả message + bôi đỏ field
        APPEND VALUE #(
          %tky     = <ls_new>-%tky
          %msg     = new_message(
                        id       = 'ZKBMAHQ'         "tạo message class của bạn
                        number   = '001'         "ví dụ: 'Đã tồn tại bản ghi TaxCode &1, TaxNo &2'
                        v1       = <ls_new>-companycode
                        v2       = <ls_new>-mahaiquan
                        v3       = <ls_new>-hinhthuc
                        severity = if_abap_behv_message=>severity-error )
          %element-companycode   = if_abap_behv=>mk-on
          %element-mahaiquan     = if_abap_behv=>mk-on
          %element-hinhthuc      = if_abap_behv=>mk-on
        ) TO reported-khai_bao_ma_hq.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD effects_text.
    " Lấy dữ liệu các bản ghi đang được sửa
    READ ENTITIES OF zrap_r_kb_mahq IN LOCAL MODE
      ENTITY khai_bao_ma_hq
      FIELDS ( companycode companycodename )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_rows).

    LOOP AT lt_rows ASSIGNING FIELD-SYMBOL(<ls>).

      " Chỉ tính lại khi có thay đổi số tiền/quantity (tránh ghi đè không cần thiết)
      DATA(lv_change_relevant) = abap_false.
      READ TABLE keys ASSIGNING FIELD-SYMBOL(<lk>)
           WITH KEY %tky = <ls>-%tky.
      IF sy-subrc = 0.
        IF <lk>-%is_draft                = abap_true. "create lần đầu
          lv_change_relevant = abap_true.
        ENDIF.
      ENDIF.

      IF lv_change_relevant = abap_false.
*        CONTINUE.
      ENDIF.

      SELECT SINGLE FROM i_companycode
      FIELDS companycodename
      WHERE companycode = @<ls>-companycode
      INTO @<ls>-companycodename.

      " Ghi ngược lại field
      MODIFY ENTITIES OF zrap_r_kb_mahq IN LOCAL MODE
        ENTITY khai_bao_ma_hq
        UPDATE FIELDS ( companycodename )
        WITH VALUE #(
          ( %tky            = <ls>-%tky
            companycode     = <ls>-companycode
            companycodename = <ls>-companycodename
          )
      )
        FAILED   DATA(ls_failed)
        REPORTED DATA(ls_reported).

    ENDLOOP.
  ENDMETHOD.

  METHOD get_companycode_name.
    MODIFY ENTITIES OF zrap_r_kb_mahq IN LOCAL MODE
        ENTITY khai_bao_ma_hq
          EXECUTE effects_text
          FROM CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD check_modify.

    me->validate_duplicate(
      EXPORTING
        keys     = keys
      CHANGING
*       failed   = failed
        reported = reported
    ).

  ENDMETHOD.

  METHOD precheck.

    TYPES: BEGIN OF lty_output,
             companycode     TYPE zrap_r_kb_mahq-companycode,
             companycodename TYPE zrap_r_kb_mahq-companycodename,
             mahaiquan       TYPE zrap_r_kb_mahq-mahaiquan,
             tenmahaiquan    TYPE zrap_r_kb_mahq-tenmahaiquan,
             hinhthuc        TYPE zrap_r_kb_mahq-hinhthuc,
             messagetype     TYPE char1,
             messagetext     TYPE string,
           END OF lty_output,

           BEGIN OF lty_cocodename,
             companycode     TYPE zrap_r_kb_mahq-companycode,
             companycodename TYPE zrap_r_kb_mahq-companycodename,
           END OF lty_cocodename.

    TYPES: BEGIN OF lty_dup_key,
             companycode TYPE zrap_r_kb_mahq-companycode,
             ma_hai_quan TYPE zrap_r_kb_mahq-mahaiquan,
             hinh_thuc   TYPE zrap_r_kb_mahq-hinhthuc,
           END OF lty_dup_key.

    DATA lt_seen_keys TYPE HASHED TABLE OF lty_dup_key
      WITH UNIQUE KEY companycode ma_hai_quan hinh_thuc.

    DATA lt_cocodename TYPE SORTED TABLE OF lty_cocodename WITH UNIQUE KEY companycode.

    DATA ls_dup_key TYPE lty_dup_key.

    DATA: lt_output TYPE STANDARD TABLE OF lty_output WITH DEFAULT KEY,
          ls_output LIKE LINE OF lt_output.

    DATA: lv_xlsx TYPE xstring.
    DATA: lv_index1 TYPE sy-tabix,
          lv_index2 TYPE sy-tabix.

    READ TABLE keys INDEX 1 INTO DATA(k).

    lv_xlsx = k-%param-filecontent.

    DATA(lt_file) = me->read_xlsx( lv_xlsx ).

    LOOP AT lt_file INTO DATA(ls_file).
      lv_index1 = sy-tabix.
      ls_output-companycode  = ls_file-companycode.

      READ TABLE lt_cocodename INTO DATA(ls_cocodename) WITH KEY companycode = ls_file-companycode BINARY SEARCH.
      IF sy-subrc EQ 0.
        ls_output-companycodename = ls_cocodename-companycodename.
      ELSE.
        SELECT SINGLE companycodename FROM i_companycode
        WHERE companycode = @ls_file-companycode
        INTO @ls_output-companycodename.
        IF sy-subrc EQ 0.
          INSERT VALUE #( companycode     = ls_output-companycode
                          companycodename = ls_output-companycodename
          ) INTO TABLE lt_cocodename.
        ENDIF.
      ENDIF.

      ls_output-mahaiquan    = ls_file-ma_hai_quan.
      ls_output-tenmahaiquan = ls_file-ten_ma_hai_quan.
      ls_output-hinhthuc     = ls_file-hinh_thuc.

      "Check duplicate trong file Excel
      ls_dup_key-companycode = ls_file-companycode.
      ls_dup_key-ma_hai_quan = ls_file-ma_hai_quan.
      ls_dup_key-hinh_thuc   = ls_file-hinh_thuc.

      INSERT ls_dup_key INTO TABLE lt_seen_keys.

      IF sy-subrc <> 0.
        ls_output-messagetype = 'E'.
        ls_output-messagetext =
          |Line: { lv_index1 } - Trùng dữ liệu trong file Excel: CompanyCode { ls_file-companycode }, Mã hải quan { ls_file-ma_hai_quan }, Hình thức { ls_file-hinh_thuc }|.
      ENDIF.

      "Check duplicate DB
      IF ls_output-messagetype IS INITIAL.
        SELECT COUNT(*) FROM zrap_kb_mahq
        WHERE companycode = @ls_file-companycode
          AND ma_hai_quan = @ls_file-ma_hai_quan
          AND hinh_thuc   = @ls_file-hinh_thuc
        INTO @DATA(lv_count).

        IF lv_count IS NOT INITIAL.
          ls_output-messagetype = 'E'.
          ls_output-messagetext = |Line: { lv_index1 } - Đã tồn tại Mã hải quan { ls_file-ma_hai_quan }|.
        ENDIF.

      ENDIF.

      IF ls_output-messagetype IS INITIAL.
        ls_output-messagetype = 'S'.
        ls_output-messagetext = 'Success'.
      ENDIF.

      APPEND ls_output TO lt_output.
      CLEAR: ls_output,
             lv_count.
    ENDLOOP.

    DATA: name_mappings TYPE /ui2/cl_json=>name_mappings.

    name_mappings = VALUE #(
        ( abap = 'companycode'     json = 'CompanyCode' )
        ( abap = 'companycodename' json = 'CompanyCodeName' )
        ( abap = 'mahaiquan'       json = 'MaHaiQuan' )
        ( abap = 'tenmahaiquan'    json = 'TenMaHaiQuan' )
        ( abap = 'hinhthuc'        json = 'HinhThuc' )
        ( abap = 'messagetype'     json = 'MessageType' )
        ( abap = 'messagetext'     json = 'MessageText' )
    ).
    DATA(lv_json) = /ui2/cl_json=>serialize(
      data          = lt_output
      name_mappings = name_mappings
    ).

    DATA lv_xstring TYPE xstring.

    lv_xstring = cl_abap_conv_codepage=>create_out(
               codepage = 'UTF-8'
             )->convert(
               source = lv_json
             ).

    APPEND VALUE #(
        %cid   = k-%cid
        %param = VALUE #(
                          mimetype      = 'application/json'
                          filename      = 'Khaibao_MaHQ.json'
                          filecontent   = lv_xstring
                          fileextension = 'json'
                          )
    ) TO result.

  ENDMETHOD.

  METHOD create_xlsx.

    "Cách dùng template có sẵn
*    DATA(lo_write_access) =
*        xco_cp_xlsx=>document->for_file_content( lv_template_xlsx )->write_access( ).
    "----------------------
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).

    DATA(lo_worksheet) = lo_write_access->get_workbook(
      )->worksheet->at_position( 1 ).

    lo_worksheet->set_name( 'Khaibao' ).

    "Set Width
    lo_worksheet->column(
      io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
                  )->set_width( 12 ).

    lo_worksheet->column(
      io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'B' )
                  )->set_width( 18 ).

    lo_worksheet->column(
      io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'C' )
                  )->set_width( 25 ).

    lo_worksheet->column(
      io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'D' )
                  )->set_width( 12 ).
    "-------------------------------------------------------------------"


    DATA(lo_font_bold) = xco_cp_xlsx=>style->font( ).
    lo_font_bold->set_bold( ).

    DATA(lo_align_center) = xco_cp_xlsx=>style->alignment( ).
    lo_align_center->set_horizontal_alignment(
        xco_cp_xlsx=>horizontal_alignment->center
      )->set_vertical_alignment(
        xco_cp_xlsx=>vertical_alignment->center
      )->set_wrap_text( ).

    DATA(lo_fill_yellow) = xco_cp_xlsx=>style->fill(
      )->set_background_color( xco_cp_xlsx=>color->standard->yellow ).

    DATA(lo_border) = xco_cp_xlsx=>style->border( ).
    lo_border->set_outline(
      io_style = xco_cp_xlsx=>border_style->thin
      io_color = xco_cp_xlsx=>color->standard->black
    ).

    "Header
    DATA(lo_cursor) = lo_worksheet->cursor(
      io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
      io_row    = xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
    ).

    lo_cursor->get_cell( )->value->write_from( 'Công ty' ).
    lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_font_bold ) ( lo_align_center ) ( lo_border ) ) ).

    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Mã hải quan' ).
    lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_font_bold ) ( lo_align_center ) ( lo_border ) ) ).

    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Tên hải quan' ).
    lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_font_bold ) ( lo_align_center ) ( lo_border ) ) ).

    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Hình thức' ).
    lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_font_bold ) ( lo_align_center ) ( lo_border ) ) ).

    DATA(lv_row) = 2.

    LOOP AT it_data INTO DATA(ls_data).

      lo_cursor = lo_worksheet->cursor(
        io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
        io_row    = xco_cp_xlsx=>coordinate->for_numeric_value( lv_row )
      ).

      lo_cursor->get_cell( )->value->write_from( ls_data-companycode ).
      IF lv_row = 3.
        lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_align_center ) ( lo_border ) ( lo_fill_yellow ) ) ).
      ELSE.
        lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_align_center ) ( lo_border ) ) ).
      ENDIF.

      lo_cursor->move_right( )->get_cell( )->value->write_from( ls_data-ma_hai_quan ).
      IF lv_row = 3.
        lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_align_center ) ( lo_border ) ( lo_fill_yellow ) ) ).
      ELSE.
        lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_align_center ) ( lo_border ) ) ).
      ENDIF.

      lo_cursor->move_right( )->get_cell( )->value->write_from( ls_data-ten_ma_hai_quan ).
      IF lv_row = 3.
        lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_align_center ) ( lo_border ) ( lo_fill_yellow ) ) ).
      ELSE.
        lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_align_center ) ( lo_border ) ) ).
      ENDIF.

      lo_cursor->move_right( )->get_cell( )->value->write_from( ls_data-hinh_thuc ).
      IF lv_row = 3.
        lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_align_center ) ( lo_border ) ( lo_fill_yellow ) ) ).
      ELSE.
        lo_cursor->get_cell( )->apply_styles( VALUE #( ( lo_align_center ) ( lo_border ) ) ).
      ENDIF.

      lv_row += 1.

    ENDLOOP.

    rv_xlsx = lo_write_access->get_file_content( ).

  ENDMETHOD.

  METHOD read_xlsx.

    DATA: lt_file TYPE tt_data.

    FINAL(lv_filecontent) = iv_xlsx.

    CHECK sy-subrc = 0.

    "XCOライブラリを使用したExcelファイルの読み取り
    FINAL(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_filecontent )->read_access( ).
    FINAL(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

    FINAL(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).

    FINAL(lo_execute) = lo_worksheet->select( lo_selection_pattern
      )->row_stream(
      )->operation->write_to( REF #( lt_file ) ).

    lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
               )->if_xco_xlsx_ra_operation~execute( ).

    IF lt_file IS NOT INITIAL.
      DO 1 TIMES.
        DELETE lt_file INDEX 1.
      ENDDO.
    ENDIF.

    DELETE lt_file WHERE table_line IS INITIAL .

    IF lt_file IS NOT INITIAL.
      MOVE-CORRESPONDING lt_file TO rt_data.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
