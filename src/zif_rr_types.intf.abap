INTERFACE zif_rr_types
  PUBLIC.

  CONSTANTS:
    BEGIN OF severity,
      error   TYPE c LENGTH 10 VALUE 'ERROR',
      warning TYPE c LENGTH 10 VALUE 'WARNING',
      info    TYPE c LENGTH 10 VALUE 'INFO',
    END OF severity,
    BEGIN OF status,
      new     TYPE c LENGTH 12 VALUE 'NEW',
      running TYPE c LENGTH 12 VALUE 'RUNNING',
      ready   TYPE c LENGTH 12 VALUE 'READY',
      blocked TYPE c LENGTH 12 VALUE 'BLOCKED',
      review  TYPE c LENGTH 12 VALUE 'REVIEW',
    END OF status.

  TYPES:
    BEGIN OF ty_context,
      package           TYPE devclass,
      transport_request TYPE trkorr,
      package_exists    TYPE abap_bool,
      transport_exists  TYPE abap_bool,
      transport_open    TYPE abap_bool,
    END OF ty_context,
    BEGIN OF ty_object,
      pgmid        TYPE pgmid,
      object_type  TYPE trobjtype,
      object_name  TYPE sobj_name,
      package      TYPE devclass,
      transport    TYPE trkorr,
      in_transport TYPE abap_bool,
    END OF ty_object,
    tt_object TYPE STANDARD TABLE OF ty_object WITH EMPTY KEY,
    BEGIN OF ty_finding,
      rule_id          TYPE c LENGTH 10,
      severity         TYPE c LENGTH 10,
      title            TYPE c LENGTH 80,
      description      TYPE c LENGTH 255,
      object_type      TYPE trobjtype,
      object_name      TYPE sobj_name,
      suggested_action TYPE c LENGTH 255,
    END OF ty_finding,
    tt_finding TYPE STANDARD TABLE OF ty_finding WITH EMPTY KEY.
ENDINTERFACE.
