CLASS zcl_rr_analyzer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES tt_rule TYPE STANDARD TABLE OF REF TO zif_rr_rule WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO zif_rr_repository
        it_rules      TYPE tt_rule.

    CLASS-METHODS create_default
      RETURNING VALUE(ro_analyzer) TYPE REF TO zcl_rr_analyzer.

    METHODS analyze
      IMPORTING
        iv_package   TYPE devclass
        iv_transport TYPE trkorr OPTIONAL
      EXPORTING
        et_objects  TYPE zif_rr_types=>tt_object
        et_findings TYPE zif_rr_types=>tt_finding.

  PRIVATE SECTION.
    DATA repository TYPE REF TO zif_rr_repository.
    DATA rules TYPE tt_rule.
ENDCLASS.

CLASS zcl_rr_analyzer IMPLEMENTATION.
  METHOD constructor.
    repository = io_repository.
    rules = it_rules.
  ENDMETHOD.

  METHOD create_default.
    ro_analyzer = NEW #(
      io_repository = NEW zcl_rr_repo_onprem( )
      it_rules      = VALUE #( ( NEW zcl_rr_rule_baseline( ) ) ) ).
  ENDMETHOD.

  METHOD analyze.
    DATA(context) = VALUE zif_rr_types=>ty_context(
      package           = iv_package
      transport_request = iv_transport
      package_exists    = repository->package_exists( iv_package )
      transport_exists  = repository->transport_exists( iv_transport )
      transport_open    = repository->transport_is_modifiable( iv_transport ) ).

    et_objects = repository->get_objects(
      iv_package   = iv_package
      iv_transport = iv_transport ).

    LOOP AT rules INTO DATA(rule).
      APPEND LINES OF rule->evaluate(
        is_context = context
        it_objects = et_objects ) TO et_findings.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
