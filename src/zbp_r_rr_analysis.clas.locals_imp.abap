CLASS lhc_analysis DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Analysis
      RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Analysis
      RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Analysis
      RESULT result.

    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Analysis~setInitialStatus.

    METHODS validateScope FOR VALIDATE ON SAVE
      IMPORTING keys FOR Analysis~validateScope.

    METHODS Analyze FOR MODIFY
      IMPORTING keys FOR ACTION Analysis~Analyze RESULT result.

    METHODS Reset FOR MODIFY
      IMPORTING keys FOR ACTION Analysis~Reset RESULT result.
ENDCLASS.

CLASS lhc_analysis IMPLEMENTATION.
  METHOD get_global_authorizations.
    AUTHORITY-CHECK OBJECT 'Z_RAPREADY'
      ID 'ACTVT' FIELD '01'
      ID 'DEVCLASS' DUMMY.
    result-%create = COND #( WHEN sy-subrc = 0
                             THEN if_abap_behv=>auth-allowed
                             ELSE if_abap_behv=>auth-unauthorized ).

    AUTHORITY-CHECK OBJECT 'Z_RAPREADY'
      ID 'ACTVT' FIELD '02'
      ID 'DEVCLASS' DUMMY.
    DATA(change_permission) = COND #( WHEN sy-subrc = 0
                                      THEN if_abap_behv=>auth-allowed
                                      ELSE if_abap_behv=>auth-unauthorized ).
    result-%update = change_permission.
    result-%action-Reset = change_permission.

    AUTHORITY-CHECK OBJECT 'Z_RAPREADY'
      ID 'ACTVT' FIELD '06'
      ID 'DEVCLASS' DUMMY.
    result-%delete = COND #( WHEN sy-subrc = 0
                             THEN if_abap_behv=>auth-allowed
                             ELSE if_abap_behv=>auth-unauthorized ).

    AUTHORITY-CHECK OBJECT 'Z_RAPREADY'
      ID 'ACTVT' FIELD '16'
      ID 'DEVCLASS' DUMMY.
    result-%action-Analyze = COND #( WHEN sy-subrc = 0
                                     THEN if_abap_behv=>auth-allowed
                                     ELSE if_abap_behv=>auth-unauthorized ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
    READ ENTITIES OF zr_rr_analysis IN LOCAL MODE
      ENTITY Analysis
      FIELDS ( ScopePackage )
      WITH CORRESPONDING #( keys )
      RESULT DATA(analyses).

    LOOP AT analyses ASSIGNING FIELD-SYMBOL(<analysis>).
      AUTHORITY-CHECK OBJECT 'Z_RAPREADY'
        ID 'ACTVT' FIELD '02'
        ID 'DEVCLASS' FIELD <analysis>-ScopePackage.
      DATA(change_permission) = COND #( WHEN sy-subrc = 0
                                        THEN if_abap_behv=>auth-allowed
                                        ELSE if_abap_behv=>auth-unauthorized ).

      AUTHORITY-CHECK OBJECT 'Z_RAPREADY'
        ID 'ACTVT' FIELD '06'
        ID 'DEVCLASS' FIELD <analysis>-ScopePackage.
      DATA(delete_permission) = COND #( WHEN sy-subrc = 0
                                        THEN if_abap_behv=>auth-allowed
                                        ELSE if_abap_behv=>auth-unauthorized ).

      AUTHORITY-CHECK OBJECT 'Z_RAPREADY'
        ID 'ACTVT' FIELD '16'
        ID 'DEVCLASS' FIELD <analysis>-ScopePackage.
      DATA(execute_permission) = COND #( WHEN sy-subrc = 0
                                         THEN if_abap_behv=>auth-allowed
                                         ELSE if_abap_behv=>auth-unauthorized ).

      APPEND VALUE #(
        %tky = <analysis>-%tky
        %update = change_permission
        %delete = delete_permission
        %action-Analyze = execute_permission
        %action-Reset = change_permission ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zr_rr_analysis IN LOCAL MODE
      ENTITY Analysis
      FIELDS ( ScopePackage Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(analyses).

    result = VALUE #(
      FOR analysis IN analyses
      ( %tky = analysis-%tky
        %field-ScopePackage = COND #(
          WHEN analysis-Status = zif_rr_types=>status-new
            THEN if_abap_behv=>fc-f-unrestricted
          ELSE if_abap_behv=>fc-f-read_only )
        %field-TransportRequest = COND #(
          WHEN analysis-Status = zif_rr_types=>status-new
            THEN if_abap_behv=>fc-f-unrestricted
          ELSE if_abap_behv=>fc-f-read_only )
        %action-Analyze = COND #(
          WHEN analysis-ScopePackage IS INITIAL
            OR analysis-Status = zif_rr_types=>status-running
            THEN if_abap_behv=>fc-o-disabled
          ELSE if_abap_behv=>fc-o-enabled )
        %action-Reset = COND #(
          WHEN analysis-Status = zif_rr_types=>status-new
            THEN if_abap_behv=>fc-o-disabled
          ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD setInitialStatus.
    MODIFY ENTITIES OF zr_rr_analysis IN LOCAL MODE
      ENTITY Analysis
      UPDATE FIELDS ( Status StatusCriticality ObjectCount ErrorCount
                      WarningCount InfoCount Score )
      WITH VALUE #( FOR key IN keys
                    ( %tky = key-%tky
                      Status = zif_rr_types=>status-new
                      StatusCriticality = 0
                      ObjectCount = 0
                      ErrorCount = 0
                      WarningCount = 0
                      InfoCount = 0
                      Score = 0 ) )
      FAILED DATA(failed_update)
      REPORTED DATA(reported_update).

    IF failed_update IS NOT INITIAL.
      LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
        APPEND VALUE #(
          %tky = <key>-%tky
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'The initial analysis state could not be set.' ) )
          TO reported-analysis.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD validateScope.
    READ ENTITIES OF zr_rr_analysis IN LOCAL MODE
      ENTITY Analysis
      FIELDS ( ScopePackage )
      WITH CORRESPONDING #( keys )
      RESULT DATA(analyses).

    LOOP AT analyses ASSIGNING FIELD-SYMBOL(<analysis>)
         WHERE ScopePackage IS INITIAL.
      APPEND VALUE #( %tky = <analysis>-%tky ) TO failed-analysis.
      APPEND VALUE #(
        %tky = <analysis>-%tky
        %element-ScopePackage = if_abap_behv=>mk-on
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'Scope package is required.' ) ) TO reported-analysis.
    ENDLOOP.

    LOOP AT analyses ASSIGNING <analysis>
         WHERE ScopePackage IS NOT INITIAL.
      AUTHORITY-CHECK OBJECT 'Z_RAPREADY'
        ID 'ACTVT' FIELD '16'
        ID 'DEVCLASS' FIELD <analysis>-ScopePackage.
      IF sy-subrc <> 0.
        APPEND VALUE #( %tky = <analysis>-%tky ) TO failed-analysis.
        APPEND VALUE #(
          %tky = <analysis>-%tky
          %element-ScopePackage = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text = 'You are not authorized to analyze this package.' ) )
          TO reported-analysis.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD Analyze.
    READ ENTITIES OF zr_rr_analysis IN LOCAL MODE
      ENTITY Analysis
      FIELDS ( ScopePackage TransportRequest )
      WITH CORRESPONDING #( keys )
      RESULT DATA(analyses).

    DATA(analyzer) = zcl_rr_analyzer=>create_default( ).
    DATA timestamp TYPE timestampl.

    LOOP AT analyses ASSIGNING FIELD-SYMBOL(<analysis>).
      MODIFY ENTITIES OF zr_rr_analysis IN LOCAL MODE
        ENTITY Analysis
        UPDATE FIELDS ( Status StatusCriticality )
        WITH VALUE #( ( %tky = <analysis>-%tky
                        Status = zif_rr_types=>status-running
                        StatusCriticality = 2 ) )
        FAILED DATA(failed_running)
        REPORTED DATA(reported_running).

      IF failed_running IS NOT INITIAL.
        APPEND VALUE #( %tky = <analysis>-%tky ) TO failed-analysis.
        APPEND VALUE #( %tky = <analysis>-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text = 'The analysis could not be started.' ) )
               TO reported-analysis.
        CONTINUE.
      ENDIF.

      analyzer->analyze(
        EXPORTING
          iv_package   = <analysis>-ScopePackage
          iv_transport = <analysis>-TransportRequest
        IMPORTING
          et_objects   = DATA(objects)
          et_findings  = DATA(findings) ).

      READ ENTITIES OF zr_rr_analysis IN LOCAL MODE
        ENTITY Analysis BY \_Findings
        FROM VALUE #( ( %tky = <analysis>-%tky ) )
        RESULT DATA(existing_findings).

      READ ENTITIES OF zr_rr_analysis IN LOCAL MODE
        ENTITY Analysis BY \_Objects
        FROM VALUE #( ( %tky = <analysis>-%tky ) )
        RESULT DATA(existing_objects).

      GET TIME STAMP FIELD timestamp.

      MODIFY ENTITIES OF zr_rr_analysis IN LOCAL MODE
        ENTITY Finding DELETE FROM VALUE #(
          FOR finding IN existing_findings ( %tky = finding-%tky ) )
        ENTITY ScannedObject DELETE FROM VALUE #(
          FOR object IN existing_objects ( %tky = object-%tky ) )
        ENTITY Analysis CREATE BY \_Findings
        FIELDS ( RuleId Severity SeverityCriticality Title Description
                 ObjectType ObjectName SuggestedAction CreatedAt )
        WITH VALUE #(
          ( %tky = <analysis>-%tky
            %target = VALUE #(
              FOR finding IN findings INDEX INTO index
              ( %cid = |F{ index }|
                RuleId = finding-rule_id
                Severity = finding-severity
                SeverityCriticality = COND #( WHEN finding-severity = zif_rr_types=>severity-error THEN 1
                                              WHEN finding-severity = zif_rr_types=>severity-warning THEN 2
                                              ELSE 3 )
                Title = finding-title
                Description = finding-description
                ObjectType = finding-object_type
                ObjectName = finding-object_name
                SuggestedAction = finding-suggested_action
                CreatedAt = timestamp ) ) ) )
        ENTITY Analysis CREATE BY \_Objects
        FIELDS ( Pgmid ObjectType ObjectName PackageName Transport InTransport CreatedAt )
        WITH VALUE #(
          ( %tky = <analysis>-%tky
            %target = VALUE #(
              FOR object IN objects INDEX INTO index
              ( %cid = |O{ index }|
                Pgmid = object-pgmid
                ObjectType = object-object_type
                ObjectName = object-object_name
                PackageName = object-package
                Transport = object-transport
                InTransport = object-in_transport
                CreatedAt = timestamp ) ) ) )
        FAILED DATA(failed_snapshot)
        REPORTED DATA(reported_snapshot).

      IF failed_snapshot IS NOT INITIAL.
        APPEND VALUE #( %tky = <analysis>-%tky ) TO failed-analysis.
        APPEND VALUE #( %tky = <analysis>-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text = 'The analysis snapshot could not be replaced.' ) )
               TO reported-analysis.
        CONTINUE.
      ENDIF.

      DATA(summary) = zcl_rr_result_calculator=>calculate( findings ).

      MODIFY ENTITIES OF zr_rr_analysis IN LOCAL MODE
        ENTITY Analysis
        UPDATE FIELDS ( Status StatusCriticality ObjectCount ErrorCount
                        WarningCount InfoCount Score )
        WITH VALUE #( ( %tky = <analysis>-%tky
                        Status = summary-status
                        StatusCriticality = summary-status_criticality
                        ObjectCount = lines( objects )
                        ErrorCount = summary-error_count
                        WarningCount = summary-warning_count
                        InfoCount = summary-info_count
                        Score = summary-score ) )
        FAILED DATA(failed_summary)
        REPORTED DATA(reported_summary).

      IF failed_summary IS NOT INITIAL.
        APPEND VALUE #( %tky = <analysis>-%tky ) TO failed-analysis.
        APPEND VALUE #( %tky = <analysis>-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text = 'The analysis summary could not be updated.' ) )
               TO reported-analysis.
      ENDIF.
    ENDLOOP.

    READ ENTITIES OF zr_rr_analysis IN LOCAL MODE
      ENTITY Analysis ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(updated_analyses).

    result = VALUE #( FOR analysis IN updated_analyses
                      ( %tky = analysis-%tky %param = analysis ) ).
  ENDMETHOD.

  METHOD Reset.
    READ ENTITIES OF zr_rr_analysis IN LOCAL MODE
      ENTITY Analysis BY \_Findings
      FROM CORRESPONDING #( keys )
      RESULT DATA(existing_findings).

    READ ENTITIES OF zr_rr_analysis IN LOCAL MODE
      ENTITY Analysis BY \_Objects
      FROM CORRESPONDING #( keys )
      RESULT DATA(existing_objects).

    MODIFY ENTITIES OF zr_rr_analysis IN LOCAL MODE
      ENTITY Finding DELETE FROM VALUE #(
        FOR finding IN existing_findings ( %tky = finding-%tky ) )
      ENTITY ScannedObject DELETE FROM VALUE #(
        FOR object IN existing_objects ( %tky = object-%tky ) )
      ENTITY Analysis UPDATE FIELDS ( Status StatusCriticality ObjectCount
                                      ErrorCount WarningCount InfoCount Score )
      WITH VALUE #( FOR key IN keys
                    ( %tky = key-%tky
                      Status = zif_rr_types=>status-new
                      StatusCriticality = 0
                      ObjectCount = 0
                      ErrorCount = 0
                      WarningCount = 0
                      InfoCount = 0
                      Score = 0 ) )
      FAILED DATA(failed_reset)
      REPORTED DATA(reported_reset).

    IF failed_reset IS NOT INITIAL.
      LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
        APPEND VALUE #( %tky = <key>-%tky ) TO failed-analysis.
        APPEND VALUE #( %tky = <key>-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text = 'The analysis could not be reset.' ) )
               TO reported-analysis.
      ENDLOOP.
    ENDIF.

    READ ENTITIES OF zr_rr_analysis IN LOCAL MODE
      ENTITY Analysis ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(updated_analyses).

    result = VALUE #( FOR analysis IN updated_analyses
                      ( %tky = analysis-%tky %param = analysis ) ).
  ENDMETHOD.
ENDCLASS.
