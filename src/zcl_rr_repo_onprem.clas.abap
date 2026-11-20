CLASS zcl_rr_repo_onprem DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_rr_repository.
ENDCLASS.

CLASS zcl_rr_repo_onprem IMPLEMENTATION.
  METHOD zif_rr_repository~package_exists.
    SELECT SINGLE devclass
      FROM tdevc
      WHERE devclass = @iv_package
      INTO @DATA(lv_package).

    rv_exists = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.

  METHOD zif_rr_repository~transport_exists.
    IF iv_transport IS INITIAL.
      rv_exists = abap_true.
      RETURN.
    ENDIF.

    SELECT SINGLE trkorr
      FROM e070
      WHERE trkorr = @iv_transport
      INTO @DATA(lv_transport).

    rv_exists = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.

  METHOD zif_rr_repository~transport_is_modifiable.
    IF iv_transport IS INITIAL.
      rv_modifiable = abap_true.
      RETURN.
    ENDIF.

    SELECT SINGLE trstatus
      FROM e070
      WHERE trkorr = @iv_transport
      INTO @DATA(lv_status).

    rv_modifiable = xsdbool( lv_status = 'D' OR lv_status = 'L' ).
  ENDMETHOD.

  METHOD zif_rr_repository~get_objects.
    TYPES:
      BEGIN OF ty_transport_key,
        pgmid    TYPE pgmid,
        object   TYPE trobjtype,
        obj_name TYPE sobj_name,
        trkorr   TYPE trkorr,
      END OF ty_transport_key,
      tt_transport_key TYPE HASHED TABLE OF ty_transport_key
        WITH UNIQUE KEY pgmid object obj_name.

    SELECT pgmid, object, obj_name, devclass
      FROM tadir
      WHERE devclass = @iv_package
        AND delflag = @space
      INTO TABLE @DATA(lt_repository_objects).

    DATA lt_transport_keys TYPE tt_transport_key.

    IF iv_transport IS NOT INITIAL.
      SELECT trkorr
        FROM e070
        WHERE trkorr = @iv_transport
           OR strkorr = @iv_transport
        INTO TABLE @DATA(lt_requests_and_tasks).

      IF lt_requests_and_tasks IS NOT INITIAL.
        SELECT pgmid, object, obj_name, trkorr
          FROM e071
          FOR ALL ENTRIES IN @lt_requests_and_tasks
          WHERE trkorr = @lt_requests_and_tasks-trkorr
          INTO TABLE @DATA(lt_e071).

        lt_transport_keys = CORRESPONDING #( lt_e071 DISCARDING DUPLICATES ).
      ENDIF.
    ENDIF.

    rt_objects = VALUE #(
      FOR ls_object IN lt_repository_objects
      LET ls_transport = VALUE #( lt_transport_keys[
                                    pgmid    = ls_object-pgmid
                                    object   = ls_object-object
                                    obj_name = ls_object-obj_name ] OPTIONAL )
      IN ( pgmid        = ls_object-pgmid
           object_type  = ls_object-object
           object_name  = ls_object-obj_name
           package      = ls_object-devclass
           transport    = ls_transport-trkorr
           in_transport = xsdbool( iv_transport IS INITIAL
                                   OR ls_transport-trkorr IS NOT INITIAL ) ) ).
  ENDMETHOD.
ENDCLASS.
