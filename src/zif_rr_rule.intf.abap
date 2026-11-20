INTERFACE zif_rr_rule
  PUBLIC.

  METHODS evaluate
    IMPORTING
      is_context TYPE zif_rr_types=>ty_context
      it_objects TYPE zif_rr_types=>tt_object
    RETURNING VALUE(rt_findings) TYPE zif_rr_types=>tt_finding.
ENDINTERFACE.
