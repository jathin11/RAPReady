# Changelog

## 0.2.0 - Unreleased

- Added inherited DCL roles for every exposed transactional projection.
- Replaced broad `S_DEVELOP` checks with package-scoped `Z_RAPREADY` global and instance authorization.
- Protected analyzed scope fields from stale snapshot changes until Reset.
- Made snapshot replacement atomic within one EML request and extracted a tested result calculator.
- Cleared analyzer output parameters for safe mass-action reuse and suppressed misleading transport findings.
- Added a 1000-object synchronous cap with blocking rule `RR014`.
- Isolated classic repository/CTS access in an adapter subpackage and documented the Tier-2 exception.
- Added repository serialization checks, a production-readiness gate, and pull-request evidence checklist.

## 0.1.0 - 2026-11-20

- Initial managed RAP business object for readiness analyses.
- Fiori elements List Report/Object Page through OData V4.
- Package and transport inventory adapter for S/4HANA on-premise.
- Baseline structural readiness rules and remediation guidance.
- Owner-isolated DCL, RAP authorization, ETags, and ABAP Unit tests.
