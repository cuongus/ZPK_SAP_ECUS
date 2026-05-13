CLASS lhc_ecusheader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ecusheader RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE ecusheader.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE ecusheader.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE ecusheader.

    METHODS read FOR READ
      IMPORTING keys FOR READ ecusheader RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK ecusheader.

    METHODS rba_ecusitems FOR READ
      IMPORTING keys_rba FOR READ ecusheader\_ecusitems FULL result_requested RESULT result LINK association_links.

    METHODS cba_ecusitems FOR MODIFY
      IMPORTING entities_cba FOR CREATE ecusheader\_ecusitems.

    METHODS savedata FOR MODIFY
      IMPORTING keys FOR ACTION ecusheader~savedata RESULT result.

    METHODS headerchange FOR MODIFY
      IMPORTING keys FOR ACTION ecusheader~headerchange RESULT result.

    METHODS formvgm FOR MODIFY
      IMPORTING keys FOR ACTION ecusheader~formvgm RESULT result.

    METHODS commercialinvoice FOR MODIFY
      IMPORTING keys FOR ACTION ecusheader~commercialinvoice RESULT result.

    METHODS formsi FOR MODIFY
      IMPORTING keys FOR ACTION ecusheader~formsi RESULT result.

    METHODS packinglist FOR MODIFY
      IMPORTING keys FOR ACTION ecusheader~packinglist RESULT result.

    METHODS salescontract FOR MODIFY
      IMPORTING keys FOR ACTION ecusheader~salescontract RESULT result.

ENDCLASS.

CLASS lhc_ecusheader IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_ecusitems.
  ENDMETHOD.

  METHOD cba_ecusitems.
  ENDMETHOD.

  METHOD savedata.
  ENDMETHOD.

  METHOD headerchange.
    zcl_prc_action_ecus=>get_instance( )->headerchange(
      EXPORTING
        keys        = keys
      CHANGING
        result      = result
        mapped      = mapped
        failed      = failed
        reported    = reported
    ).
  ENDMETHOD.

  METHOD formvgm.
    zcl_prc_action_ecus=>get_instance( )->formvgm(
      EXPORTING
        keys = keys
      CHANGING
        result = result
        mapped = mapped
        failed = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD commercialinvoice.
    zcl_prc_action_ecus=>get_instance( )->commercialinvoice(
        EXPORTING
          keys = keys
        CHANGING
          result = result
          mapped = mapped
          failed = failed
          reported = reported
      ).
  ENDMETHOD.

  METHOD formsi.
    zcl_prc_action_ecus=>get_instance( )->formsi(
      EXPORTING
        keys = keys
      CHANGING
        result = result
        mapped = mapped
        failed = failed
        reported = reported
    ).
  ENDMETHOD.

  METHOD packinglist.
    zcl_prc_action_ecus=>get_instance( )->packinglist(
        EXPORTING
          keys = keys
        CHANGING
          result = result
          mapped = mapped
          failed = failed
          reported = reported
      ).
  ENDMETHOD.

  METHOD salescontract.
    zcl_prc_action_ecus=>get_instance( )->salescontract(
      EXPORTING
        keys = keys
      CHANGING
        result = result
        mapped = mapped
        failed = failed
        reported = reported
    ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ecusitems DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE ecusitems.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE ecusitems.

    METHODS read FOR READ
      IMPORTING keys FOR READ ecusitems RESULT result.

    METHODS rba_ecusheader FOR READ
      IMPORTING keys_rba FOR READ ecusitems\_ecusheader FULL result_requested RESULT result LINK association_links.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ecusitems RESULT result.

    METHODS itemchange FOR MODIFY
      IMPORTING keys FOR ACTION ecusitems~itemchange RESULT result.

ENDCLASS.

CLASS lhc_ecusitems IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_ecusheader.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD itemchange.
    zcl_prc_action_ecus=>get_instance( )->itemchange(
        EXPORTING
        keys        = keys
        CHANGING
        result      = result
        mapped      = mapped
        failed      = failed
        reported    = reported
    ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zcs_ecus_header DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zcs_ecus_header IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    zcl_prc_action_ecus=>get_instance( )->save( CHANGING reported = reported ).
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
