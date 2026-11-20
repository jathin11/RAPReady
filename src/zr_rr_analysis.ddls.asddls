@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'RAPReady Analysis'
@Search.searchable: true
define root view entity ZR_RR_Analysis
  as select from zrr_analysis
  composition [0..*] of ZR_RR_Finding as _Findings
  composition [0..*] of ZR_RR_Object  as _Objects
{
  key analysis_uuid        as AnalysisUUID,

      @Search.defaultSearchElement: true
      scope_package        as ScopePackage,

      @Search.defaultSearchElement: true
      transport_request    as TransportRequest,

      status               as Status,
      status_criticality   as StatusCriticality,
      object_count         as ObjectCount,
      error_count          as ErrorCount,
      warning_count        as WarningCount,
      info_count           as InfoCount,
      score                as Score,

      @Semantics.user.createdBy: true
      created_by           as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      created_at           as CreatedAt,

      @Semantics.user.lastChangedBy: true
      last_changed_by      as LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at      as LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Findings,
      _Objects
}
