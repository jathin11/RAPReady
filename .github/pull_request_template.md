## Change summary

Describe the behavior and contract affected by this change.

## Repository checks

- [ ] Serialization validator passes
- [ ] New or changed rules have positive and negative ABAP Unit tests
- [ ] Documentation and rule IDs are updated
- [ ] No credentials, internal hosts, customer data, or production metadata are included

## SAP-system evidence required before release

- [ ] Clean abapGit pull into the supported S/4HANA release
- [ ] Package-wide activation without warnings
- [ ] ABAP Unit passes and measured meaningful coverage is at least 80%
- [ ] ATC security, performance, S/4HANA readiness and Clean Core variants pass
- [ ] RAP create/update/delete/action and failure mapping tests pass
- [ ] DCL owner isolation and package authorization are tested with two users
- [ ] ETag/concurrency and mass Analyze tests pass
- [ ] OData V4 metadata, paging, filtering and Fiori preview tests pass
- [ ] Service publication, FLP content and target-system roles are verified

## Compatibility

State the SAP_BASIS/S4CORE level used for activation and list any Tier-2 exceptions.
