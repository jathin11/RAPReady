@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'RAPReady Scanned Object'
@Search.searchable: true
define view entity ZR_RR_Object
  as select from zrr_object
  association to parent ZR_RR_Analysis as _Analysis
    on $projection.AnalysisUUID = _Analysis.AnalysisUUID
{
  key analysis_uuid as AnalysisUUID,
  key object_uuid   as ObjectUUID,

      pgmid         as Pgmid,
      object_type   as ObjectType,

      @Search.defaultSearchElement: true
      object_name   as ObjectName,

      devclass      as PackageName,
      transport     as Transport,
      in_transport  as InTransport,

      @Semantics.systemDateTime.createdAt: true
      created_at    as CreatedAt,

      _Analysis
}
