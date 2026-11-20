CLASS lhc_analysis DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Analysis
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
    AUTHORITY-CHECK OBJECT 'S_DEVELOP'
      ID 'ACTVT' FIELD '02'
      ID 'DEVCLASS' DUMMY
      ID 'OBJTYPE' DUMMY
      ID 'OBJNAME' DUMMY
      ID 'P_GROUP' DUMMY.

    DATA(permission) = COND #( WHEN sy-subrc = 0
                               THEN if_abap_behv=>auth-allowed
                               ELSE if_abap_behv=>auth-unauthorized ).

    result-%create = permission.
    result-%update = permission.
    result-%delete = permission.
    result-%action-Analyze = permission.
    result-%action-Reset = permission.
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
      APPEND VALUE #( %msg = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text = 'The initial analysis state could not be set.' ) )
             TO reported-analysis.
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

      MODIFY ENTITIES OF zr_rr_analysis IN LOCAL MODE
        ENTITY Finding DELETE FROM VALUE #(
          FOR finding IN existing_findings ( %tky = finding-%tky ) )
        ENTITY ScannedObject DELETE FROM VALUE #(
          FOR object IN existing_objects ( %tky = object-%tky ) )
        FAILED DATA(failed_delete)
        REPORTED DATA(reported_delete).

      IF failed_delete IS NOT INITIAL.
        APPEND VALUE #( %tky = <analysis>-%tky ) TO failed-analysis.
        APPEND VALUE #( %tky = <analysis>-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text = 'The previous analysis snapshot could not be replaced.' ) )
               TO reported-analysis.
        CONTINUE.
      ENDIF.

      GET TIME STAMP FIELD timestamp.

      MODIFY ENTITIES OF zr_rr_analysis IN LOCAL MODE
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
        FAILED DATA(failed_create)
        REPORTED DATA(reported_create).

      IF failed_create IS NOT INITIAL.
        APPEND VALUE #( %tky = <analysis>-%tky ) TO failed-analysis.
        APPEND VALUE #( %tky = <analysis>-%tky
                        %msg = new_message_with_text(
                          severity = if_abap_behv_message=>severity-error
                          text = 'The analysis result could not be persisted.' ) )
               TO reported-analysis.
        CONTINUE.
      ENDIF.

      DATA(error_count) = REDUCE i(
        INIT count = 0
        FOR finding IN findings
        WHERE ( severity = zif_rr_types=>severity-error )
        NEXT count = count + 1 ).
      DATA(warning_count) = REDUCE i(
        INIT count = 0
        FOR finding IN findings
        WHERE ( severity = zif_rr_types=>severity-warning )
        NEXT count = count + 1 ).
      DATA(info_count) = REDUCE i(
        INIT count = 0
        FOR finding IN findings
        WHERE ( severity = zif_rr_types=>severity-info )
        NEXT count = count + 1 ).

      DATA(score) = 100 - ( error_count * 20 ) - ( warning_count * 5 ).
      IF score < 0.
        score = 0.
      ENDIF.

      DATA(status) = COND #( WHEN error_count > 0 THEN zif_rr_types=>status-blocked
                             WHEN warning_count > 0 THEN zif_rr_types=>status-review
                             ELSE zif_rr_types=>status-ready ).
      DATA(criticality) = COND i( WHEN error_count > 0 THEN 1
                                  WHEN warning_count > 0 THEN 2
                                  ELSE 3 ).

      MODIFY ENTITIES OF zr_rr_analysis IN LOCAL MODE
        ENTITY Analysis
        UPDATE FIELDS ( Status StatusCriticality ObjectCount ErrorCount
                        WarningCount InfoCount Score )
        WITH VALUE #( ( %tky = <analysis>-%tky
                        Status = status
                        StatusCriticality = criticality
                        ObjectCount = lines( objects )
                        ErrorCount = error_count
                        WarningCount = warning_count
                        InfoCount = info_count
                        Score = score ) )
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
