# Production readiness gate

Passing GitHub repository checks does not mean that ABAP artifacts activate or run correctly. A release is eligible for a production tag only after the following evidence is attached to its pull request or release record.

| Area | Required evidence |
| --- | --- |
| Import | Clean abapGit pull into the supported S/4HANA 2022 support-package level |
| Activation | Package-wide activation and syntax check without warnings |
| Unit tests | ABAP Unit result and at least 80% meaningful decision coverage |
| ATC | Security, performance, S/4HANA readiness and Clean Core variants |
| RAP behavior | Create, update, delete, Analyze, Reset, mass action and failure mapping |
| Authorization | Owner DCL, projection DCL inheritance, package authorization and negative-user tests |
| Concurrency | Stale ETag rejection and concurrent Analyze/Reset behavior |
| Scale | Representative packages below and above the 1000-object synchronous limit |
| OData V4 | Metadata, paging, filtering, actions, error payloads and Fiori elements preview |
| Deployment | Published binding, ICF/Gateway prerequisites, FLP target mapping, catalogs and roles |
| Recovery | Unpublish/rollback procedure and retention decision for analysis tables |

## Authorization object

`Z_RAPREADY` contains `DEVCLASS` and `ACTVT`.

| Activity | Meaning |
| --- | --- |
| 01 | Create an analysis record |
| 02 | Change or reset an analysis |
| 03 | Display authorization reserved for role design |
| 06 | Delete an analysis |
| 16 | Execute Analyze for the permitted package pattern |

The application additionally restricts read access to the creating user through CDS access control. Grant only the package patterns needed by the developer or release engineer.

## Large-package behavior

Interactive analysis is capped at 1000 TADIR objects. Exceeding the limit produces blocking finding `RR014`, so a partial snapshot can never receive READY status. Organizations needing larger scopes should implement an application-job adapter with chunking, progress, cancellation, and idempotent result replacement.

## Tier-2 exception record

| Property | Value |
| --- | --- |
| Dependency | Read-only access to `TADIR`, `TDEVC`, `E070`, and `E071` |
| Boundary | Adapter subpackage (`src/adapter`), `ZIF_RR_REPOSITORY` / `ZCL_RR_REPO_ONPREM` |
| Justification | Package and CTS metadata are the subject of the analysis |
| Write access | None |
| Target | S/4HANA 2022 on-premise, exact support package to be verified |
| Owner | Repository maintainer and adopting SAP platform team |
| Review trigger | Each S/4HANA upgrade or availability of a released replacement API |

This record documents an internal governed contract; it does not claim that the wrapped SAP tables are released APIs.
