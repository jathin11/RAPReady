CLASS ltc_baseline_rule DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA cut TYPE REF TO zif_rr_rule.

    METHODS setup.
    METHODS rejects_empty_scope FOR TESTING.
    METHODS flags_local_package FOR TESTING.
    METHODS flags_missing_transport FOR TESTING.
    METHODS accepts_complete_scope FOR TESTING.
ENDCLASS.

CLASS ltc_baseline_rule IMPLEMENTATION.
  METHOD setup.
    cut = NEW zcl_rr_rule_baseline( ).
  ENDMETHOD.

  METHOD rejects_empty_scope.
    DATA(findings) = cut->evaluate(
      is_context = VALUE #( )
      it_objects = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists( findings[ rule_id = 'RR001' ] ) ) ).
  ENDMETHOD.

  METHOD flags_local_package.
    DATA(findings) = cut->evaluate(
      is_context = VALUE #( package = '$TMP' package_exists = abap_true )
      it_objects = VALUE #( ( object_type = 'DDLS' object_name = 'ZR_TEST' ) ) ).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists( findings[ rule_id = 'RR002' ] ) ) ).
  ENDMETHOD.

  METHOD flags_missing_transport.
    DATA(findings) = cut->evaluate(
      is_context = VALUE #( package = 'ZRAPREADY'
                            package_exists = abap_true
                            transport_request = 'DEVK900001'
                            transport_exists = abap_false )
      it_objects = VALUE #( ( object_type = 'DDLS' object_name = 'ZR_TEST' in_transport = abap_false ) ) ).

    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists( findings[ rule_id = 'RR005' ] ) ) ).
    cl_abap_unit_assert=>assert_true(
      act = xsdbool( line_exists( findings[ rule_id = 'RR007' ] ) ) ).
  ENDMETHOD.

  METHOD accepts_complete_scope.
    DATA(objects) = VALUE zif_rr_types=>tt_object(
      ( object_type = 'DDLS' object_name = 'ZR_TEST' in_transport = abap_true )
      ( object_type = 'BDEF' object_name = 'ZR_TEST' in_transport = abap_true )
      ( object_type = 'SRVD' object_name = 'ZUI_TEST' in_transport = abap_true )
      ( object_type = 'SRVB' object_name = 'ZUI_TEST_O4' in_transport = abap_true )
      ( object_type = 'DCLS' object_name = 'ZR_TEST' in_transport = abap_true )
      ( object_type = 'CLAS' object_name = 'ZCL_TEST_RUNNER' in_transport = abap_true ) ).

    DATA(findings) = cut->evaluate(
      is_context = VALUE #( package = 'ZRAPREADY'
                            package_exists = abap_true
                            transport_request = 'DEVK900001'
                            transport_exists = abap_true
                            transport_open = abap_true )
      it_objects = objects ).

    cl_abap_unit_assert=>assert_initial( findings ).
  ENDMETHOD.
ENDCLASS.
