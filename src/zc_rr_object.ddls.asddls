@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'RAPReady Scanned Object'
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_RR_Object
  as projection on ZR_RR_Object
{
  key AnalysisUUID,
  key ObjectUUID,
      Pgmid,
      ObjectType,
      ObjectName,
      PackageName,
      Transport,
      InTransport,
      CreatedAt,
      _Analysis : redirected to parent ZC_RR_Analysis
}
