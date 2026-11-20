INTERFACE zif_rr_repository
  PUBLIC.

  METHODS package_exists
    IMPORTING iv_package       TYPE devclass
    RETURNING VALUE(rv_exists) TYPE abap_bool.

  METHODS transport_exists
    IMPORTING iv_transport     TYPE trkorr
    RETURNING VALUE(rv_exists) TYPE abap_bool.

  METHODS transport_is_modifiable
    IMPORTING iv_transport         TYPE trkorr
    RETURNING VALUE(rv_modifiable) TYPE abap_bool.

  METHODS get_objects
    IMPORTING
      iv_package   TYPE devclass
      iv_transport TYPE trkorr OPTIONAL
    RETURNING VALUE(rt_objects) TYPE zif_rr_types=>tt_object.
ENDINTERFACE.
