CLASS zcl_rr_rule_baseline DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_rr_rule.

  PRIVATE SECTION.
    METHODS add_finding
      IMPORTING
        iv_rule_id          TYPE c LENGTH 10
        iv_severity         TYPE c LENGTH 10
        iv_title            TYPE c LENGTH 80
        iv_description      TYPE c LENGTH 255
        iv_object_type      TYPE trobjtype OPTIONAL
        iv_object_name      TYPE sobj_name OPTIONAL
        iv_suggested_action TYPE c LENGTH 255
      CHANGING
        ct_findings TYPE zif_rr_types=>tt_finding.
ENDCLASS.

CLASS zcl_rr_rule_baseline IMPLEMENTATION.
  METHOD zif_rr_rule~evaluate.
    IF is_context-package IS INITIAL.
      add_finding(
        EXPORTING
          iv_rule_id          = 'RR001'
          iv_severity         = zif_rr_types=>severity-error
          iv_title            = 'Scope package is required'
          iv_description      = 'The analysis cannot resolve repository objects without a package.'
          iv_suggested_action = 'Enter a package and run Analyze again.'
        CHANGING
          ct_findings         = rt_findings ).
      RETURN.
    ENDIF.

    IF is_context-package = '$TMP'.
      add_finding(
        EXPORTING
          iv_rule_id          = 'RR002'
          iv_severity         = zif_rr_types=>severity-error
          iv_title            = 'Local package is not transportable'
          iv_description      = 'Objects in $TMP cannot be delivered through the normal CTS path.'
          iv_suggested_action = 'Move the objects to an approved transportable package.'
        CHANGING
          ct_findings         = rt_findings ).
    ENDIF.

    IF is_context-package_exists = abap_false.
      add_finding(
        EXPORTING
          iv_rule_id          = 'RR003'
          iv_severity         = zif_rr_types=>severity-error
          iv_title            = 'Package does not exist'
          iv_description      = 'No package with the supplied name was found in TDEVC.'
          iv_suggested_action = 'Correct the package name or create it through the governed package process.'
        CHANGING
          ct_findings         = rt_findings ).
      RETURN.
    ENDIF.

    IF it_objects IS INITIAL.
      add_finding(
        EXPORTING
          iv_rule_id          = 'RR004'
          iv_severity         = zif_rr_types=>severity-error
          iv_title            = 'Package contains no repository objects'
          iv_description      = 'No non-deleted TADIR entries were found for the package.'
          iv_suggested_action = 'Verify package assignment and activate the intended objects.'
        CHANGING
          ct_findings         = rt_findings ).
    ENDIF.

    IF is_context-object_limit_exceeded = abap_true.
      add_finding(
        EXPORTING
          iv_rule_id          = 'RR014'
          iv_severity         = zif_rr_types=>severity-error
          iv_title            = 'Package exceeds the synchronous scan limit'
          iv_description      = 'The package contains more than 1000 objects; the persisted snapshot is intentionally incomplete.'
          iv_suggested_action = 'Analyze a smaller package scope or implement the documented background-job extension.'
        CHANGING
          ct_findings         = rt_findings ).
    ENDIF.

    IF is_context-transport_request IS NOT INITIAL.
      IF is_context-transport_exists = abap_false.
        add_finding(
          EXPORTING
            iv_rule_id          = 'RR005'
            iv_severity         = zif_rr_types=>severity-error
            iv_title            = 'Transport request does not exist'
            iv_description      = 'The supplied request or task is not present in E070.'
            iv_suggested_action = 'Correct the transport number or clear it for a package-only analysis.'
          CHANGING
            ct_findings         = rt_findings ).
      ELSE.
        IF is_context-transport_open = abap_false.
          add_finding(
            EXPORTING
              iv_rule_id          = 'RR006'
              iv_severity         = zif_rr_types=>severity-warning
              iv_title            = 'Transport is not modifiable'
              iv_description      = 'The selected request is no longer in a modifiable or protected state.'
              iv_suggested_action = 'Use a modifiable request for corrections or treat this run as an audit.'
            CHANGING
              ct_findings         = rt_findings ).
        ENDIF.

        LOOP AT it_objects ASSIGNING FIELD-SYMBOL(<object>)
             WHERE in_transport = abap_false.
          add_finding(
            EXPORTING
              iv_rule_id          = 'RR007'
              iv_severity         = zif_rr_types=>severity-error
              iv_title            = 'Object is missing from the transport'
              iv_description      = 'The package object is not represented in the selected request or its tasks.'
              iv_object_type      = <object>-object_type
              iv_object_name      = <object>-object_name
              iv_suggested_action = 'Add the object through the normal transport organizer workflow.'
            CHANGING
              ct_findings         = rt_findings ).
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF NOT line_exists( it_objects[ object_type = 'DDLS' ] ).
      add_finding(
        EXPORTING iv_rule_id = 'RR008' iv_severity = zif_rr_types=>severity-warning
                  iv_title = 'No CDS DDL source found'
                  iv_description = 'The package has no DDLS repository object.'
                  iv_suggested_action = 'Verify the RAP scope and transport the required CDS entities.'
        CHANGING ct_findings = rt_findings ).
    ENDIF.

    IF NOT line_exists( it_objects[ object_type = 'BDEF' ] ).
      add_finding(
        EXPORTING iv_rule_id = 'RR009' iv_severity = zif_rr_types=>severity-warning
                  iv_title = 'No behavior definition found'
                  iv_description = 'The package has no BDEF repository object.'
                  iv_suggested_action = 'Add or transport the RAP behavior definition.'
        CHANGING ct_findings = rt_findings ).
    ENDIF.

    IF NOT line_exists( it_objects[ object_type = 'SRVD' ] ).
      add_finding(
        EXPORTING iv_rule_id = 'RR010' iv_severity = zif_rr_types=>severity-warning
                  iv_title = 'No service definition found'
                  iv_description = 'The package has no SRVD repository object.'
                  iv_suggested_action = 'Add or transport the service definition.'
        CHANGING ct_findings = rt_findings ).
    ENDIF.

    IF NOT line_exists( it_objects[ object_type = 'SRVB' ] ).
      add_finding(
        EXPORTING iv_rule_id = 'RR011' iv_severity = zif_rr_types=>severity-warning
                  iv_title = 'No service binding found'
                  iv_description = 'The package has no SRVB repository object.'
                  iv_suggested_action = 'Add or transport an OData service binding and publish it in the target system.'
        CHANGING ct_findings = rt_findings ).
    ENDIF.

    IF NOT line_exists( it_objects[ object_type = 'DCLS' ] ).
      add_finding(
        EXPORTING iv_rule_id = 'RR012' iv_severity = zif_rr_types=>severity-warning
                  iv_title = 'No CDS access control found'
                  iv_description = 'The package has no DCLS repository object.'
                  iv_suggested_action = 'Review read authorization and add DCL where the service contract requires it.'
        CHANGING ct_findings = rt_findings ).
    ENDIF.

    DATA(lv_has_test_class) = abap_false.
    LOOP AT it_objects ASSIGNING <object> WHERE object_type = 'CLAS'.
      IF <object>-object_name CS 'TEST' OR <object>-object_name CS 'LTC'.
        lv_has_test_class = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_has_test_class = abap_false.
      add_finding(
        EXPORTING iv_rule_id = 'RR013' iv_severity = zif_rr_types=>severity-info
                  iv_title = 'No test class is discoverable by name'
                  iv_description = 'No CLAS object contains TEST or LTC; local test includes are not visible in TADIR.'
                  iv_suggested_action = 'Verify ABAP Unit coverage in ADT and enforce the measured threshold in CI.'
        CHANGING ct_findings = rt_findings ).
    ENDIF.
  ENDMETHOD.

  METHOD add_finding.
    APPEND VALUE #(
      rule_id          = iv_rule_id
      severity         = iv_severity
      title            = iv_title
      description      = iv_description
      object_type      = iv_object_type
      object_name      = iv_object_name
      suggested_action = iv_suggested_action ) TO ct_findings.
  ENDMETHOD.
ENDCLASS.
