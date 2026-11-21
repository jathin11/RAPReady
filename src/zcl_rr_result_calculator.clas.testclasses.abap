CLASS ltc_result_calculator DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS returns_ready FOR TESTING.
    METHODS returns_review FOR TESTING.
    METHODS returns_blocked FOR TESTING.
    METHODS clamps_score_at_zero FOR TESTING.
ENDCLASS.

CLASS ltc_result_calculator IMPLEMENTATION.
  METHOD returns_ready.
    DATA(summary) = zcl_rr_result_calculator=>calculate( VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = summary-status exp = zif_rr_types=>status-ready ).
    cl_abap_unit_assert=>assert_equals( act = summary-score exp = 100 ).
  ENDMETHOD.

  METHOD returns_review.
    DATA(summary) = zcl_rr_result_calculator=>calculate(
      VALUE #( ( severity = zif_rr_types=>severity-warning )
               ( severity = zif_rr_types=>severity-info ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = summary-status exp = zif_rr_types=>status-review ).
    cl_abap_unit_assert=>assert_equals( act = summary-warning_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = summary-info_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = summary-score exp = 95 ).
  ENDMETHOD.

  METHOD returns_blocked.
    DATA(summary) = zcl_rr_result_calculator=>calculate(
      VALUE #( ( severity = zif_rr_types=>severity-error ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = summary-status exp = zif_rr_types=>status-blocked ).
    cl_abap_unit_assert=>assert_equals( act = summary-error_count exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = summary-score exp = 80 ).
  ENDMETHOD.

  METHOD clamps_score_at_zero.
    DATA findings TYPE zif_rr_types=>tt_finding.
    DO 6 TIMES.
      APPEND VALUE #( severity = zif_rr_types=>severity-error ) TO findings.
    ENDDO.

    DATA(summary) = zcl_rr_result_calculator=>calculate( findings ).

    cl_abap_unit_assert=>assert_equals( act = summary-score exp = 0 ).
  ENDMETHOD.
ENDCLASS.
