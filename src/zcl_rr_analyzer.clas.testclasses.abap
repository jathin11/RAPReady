CLASS lcl_repository_fake DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_rr_repository.
ENDCLASS.

CLASS lcl_repository_fake IMPLEMENTATION.
  METHOD zif_rr_repository~package_exists.
    rv_exists = abap_true.
  ENDMETHOD.

  METHOD zif_rr_repository~transport_exists.
    rv_exists = abap_true.
  ENDMETHOD.

  METHOD zif_rr_repository~transport_is_modifiable.
    rv_modifiable = abap_true.
  ENDMETHOD.

  METHOD zif_rr_repository~get_objects.
    rt_objects = VALUE #( ( object_type = 'DDLS' object_name = 'ZR_DEMO' package = iv_package ) ).
  ENDMETHOD.

  METHOD zif_rr_repository~count_objects.
    rv_count = 1.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_rule_fake DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_rr_rule.
ENDCLASS.

CLASS lcl_rule_fake IMPLEMENTATION.
  METHOD zif_rr_rule~evaluate.
    rt_findings = VALUE #( ( rule_id = 'TEST' severity = zif_rr_types=>severity-info
                             title = 'Fake rule executed' ) ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_analyzer DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS delegates_to_ports FOR TESTING.
    METHODS clears_previous_results FOR TESTING.
ENDCLASS.

CLASS ltc_analyzer IMPLEMENTATION.
  METHOD delegates_to_ports.
    DATA(cut) = NEW zcl_rr_analyzer(
      io_repository = NEW lcl_repository_fake( )
      it_rules      = VALUE #( ( NEW lcl_rule_fake( ) ) ) ).

    cut->analyze(
      EXPORTING iv_package = 'ZRAPREADY'
      IMPORTING et_objects = DATA(objects)
                et_findings = DATA(findings) ).

    cl_abap_unit_assert=>assert_equals( act = lines( objects ) exp = 1 ).
    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists( findings[ rule_id = 'TEST' ] ) ) ).
  ENDMETHOD.

  METHOD clears_previous_results.
    DATA(cut) = NEW zcl_rr_analyzer(
      io_repository = NEW lcl_repository_fake( )
      it_rules      = VALUE #( ( NEW lcl_rule_fake( ) ) ) ).
    DATA findings TYPE zif_rr_types=>tt_finding.
    findings = VALUE #( ( rule_id = 'OLD' ) ).

    cut->analyze(
      EXPORTING iv_package = 'ZRAPREADY'
      IMPORTING et_objects = DATA(objects)
                et_findings = findings ).

    cl_abap_unit_assert=>assert_equals( act = lines( findings ) exp = 1 ).
    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( findings[ rule_id = 'OLD' ] ) ) ).
  ENDMETHOD.
ENDCLASS.
