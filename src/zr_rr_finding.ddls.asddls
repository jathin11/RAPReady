@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'RAPReady Finding'
@Search.searchable: true
define view entity ZR_RR_Finding
  as select from zrr_finding
  association to parent ZR_RR_Analysis as _Analysis
    on $projection.AnalysisUUID = _Analysis.AnalysisUUID
{
  key analysis_uuid       as AnalysisUUID,
  key finding_uuid        as FindingUUID,

      rule_id             as RuleId,
      severity            as Severity,
      severity_criticality as SeverityCriticality,
      title               as Title,
      description         as Description,

      @Search.defaultSearchElement: true
      object_type         as ObjectType,

      @Search.defaultSearchElement: true
      object_name         as ObjectName,

      suggested_action    as SuggestedAction,

      @Semantics.systemDateTime.createdAt: true
      created_at          as CreatedAt,

      _Analysis
}
