CLASS zcl_rr_result_calculator DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS calculate
      IMPORTING it_findings TYPE zif_rr_types=>tt_finding
      RETURNING VALUE(rs_summary) TYPE zif_rr_types=>ty_summary.
ENDCLASS.

CLASS zcl_rr_result_calculator IMPLEMENTATION.
  METHOD calculate.
    rs_summary-error_count = REDUCE i(
      INIT count = 0
      FOR finding IN it_findings
      WHERE ( severity = zif_rr_types=>severity-error )
      NEXT count = count + 1 ).
    rs_summary-warning_count = REDUCE i(
      INIT count = 0
      FOR finding IN it_findings
      WHERE ( severity = zif_rr_types=>severity-warning )
      NEXT count = count + 1 ).
    rs_summary-info_count = REDUCE i(
      INIT count = 0
      FOR finding IN it_findings
      WHERE ( severity = zif_rr_types=>severity-info )
      NEXT count = count + 1 ).

    rs_summary-score = 100
      - ( rs_summary-error_count * 20 )
      - ( rs_summary-warning_count * 5 ).
    IF rs_summary-score < 0.
      rs_summary-score = 0.
    ENDIF.

    rs_summary-status = COND #(
      WHEN rs_summary-error_count > 0
        THEN zif_rr_types=>status-blocked
      WHEN rs_summary-warning_count > 0
        THEN zif_rr_types=>status-review
      ELSE zif_rr_types=>status-ready ).
    rs_summary-status_criticality = COND i(
      WHEN rs_summary-error_count > 0 THEN 1
      WHEN rs_summary-warning_count > 0 THEN 2
      ELSE 3 ).
  ENDMETHOD.
ENDCLASS.
