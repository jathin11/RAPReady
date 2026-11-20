@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'RAPReady Analysis'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_RR_Analysis
  provider contract transactional_query
  as projection on ZR_RR_Analysis
{
  key AnalysisUUID,
      ScopePackage,
      TransportRequest,
      Status,
      StatusCriticality,
      ObjectCount,
      ErrorCount,
      WarningCount,
      InfoCount,
      Score,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      _Findings : redirected to composition child ZC_RR_Finding,
      _Objects  : redirected to composition child ZC_RR_Object
}
