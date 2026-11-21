# Rule reference

Rules return immutable findings for one analysis snapshot. A finding contains the rule ID, severity, title, description, optional repository object, and suggested action.

Severity maps to Fiori criticality as follows: Error = 1, Warning = 2, Info = 3.

## Baseline rules

| ID | Condition | Suggested response |
| --- | --- | --- |
| RR001 | Scope package is initial | Enter a package and rerun the analysis. |
| RR002 | Scope is `$TMP` | Move objects to a transportable package. |
| RR003 | Package is not found in TDEVC | Correct or create the package. |
| RR004 | No active TADIR entries are found | Verify package content and object activation. |
| RR005 | Selected request is absent from E070 | Correct the request or leave it blank. |
| RR006 | Request status is not modifiable/protected | Use a modifiable request for corrections or treat the run as audit-only. |
| RR007 | A scoped TADIR object is not represented in E071 | Add the missing object through the normal transport organizer workflow. |
| RR008 | No DDLS exists in the package | Verify whether the package is really a RAP scope. |
| RR009 | No BDEF exists | Add or transport the behavior definition. |
| RR010 | No SRVD exists | Add or transport the service definition. |
| RR011 | No SRVB exists | Add or transport the OData service binding. |
| RR012 | No DCLS exists | Review read authorization and add DCL when required. |
| RR013 | No repository class name contains `TEST` or `LTC` | Add discoverable ABAP Unit coverage and enforce it in CI. |
| RR014 | The package contains more than 1000 active TADIR objects | Reduce the scope or use a chunked background-job extension; the partial synchronous inventory is blocked. |

## Adding a rule

1. Implement `ZIF_RR_RULE`.
2. Use a stable uppercase ID in the `RRxxx` namespace or a namespaced community range.
3. Keep evaluation deterministic and free of side effects.
4. Do not commit, publish, release, or modify repository/transport content.
5. Add the rule to `ZCL_RR_ANALYZER=>CREATE_DEFAULT`.
6. Add positive, negative, boundary, and mass-input tests.
7. Document release-sensitive APIs and expected performance.
