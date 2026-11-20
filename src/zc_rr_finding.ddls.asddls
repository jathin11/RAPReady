@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'RAPReady Finding'
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_RR_Finding
  as projection on ZR_RR_Finding
{
  key AnalysisUUID,
  key FindingUUID,
      RuleId,
      Severity,
      SeverityCriticality,
      Title,
      Description,
      ObjectType,
      ObjectName,
      SuggestedAction,
      CreatedAt,
      _Analysis : redirected to parent ZC_RR_Analysis
}
