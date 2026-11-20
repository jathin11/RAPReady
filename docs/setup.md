# Setup and operation

## Import

1. Start Eclipse and open the ABAP perspective.
2. Connect to the target S/4HANA development system.
3. Create package `ZRAPREADY` or select the approved package allocated by your namespace and transport policy.
4. Open abapGit, add online repository `https://github.com/jathin11/RAPReady`, select the package, and pull.
5. Activate the package using the order in the main README.
6. Resolve release-specific syntax only after confirming the installed SAP_BASIS/S4CORE level; do not replace a missing released API with an undocumented SAP object.

## Validate

1. Run **Activate All** on the package.
2. Run ABAP Unit on `ZCL_RR_RULE_BASELINE` and `ZCL_RR_ANALYZER`.
3. Run the project ATC variants.
4. Confirm that DCL owner isolation works with two test users.
5. Confirm `S_DEVELOP` display/change behavior with representative developer roles.

## Publish and preview

1. Open `ZUI_RR_ANALYSIS_O4` in ADT.
2. Choose **Publish**. Publication is intentionally not assumed by the Git serialization.
3. Select the `Analysis` entity set and choose **Preview**.
4. Create and save an analysis.
5. Enter the package and, optionally, one request/task number.
6. Choose **Analyze**.
7. Review the summary, Findings facet, and Scanned Objects facet.

## Launchpad deployment

Create target mapping and tile content according to the launchpad technology used in your landscape. Assign the catalog/space/page through normal role governance. Do not use the UI button visibility as an authorization control; backend DCL and behavior authorization remain mandatory.

## Operational guidance

- Run an analysis before transport release and again after the final transport merge.
- Store the analysis UUID or exported OData result with the change record if an auditable release trail is needed.
- Treat an Error result as blocked unless an approved delivery process explicitly accepts it.
- Treat Info findings as review prompts, not automatic failures.
- Run ATC and ABAP Unit outside the interactive RAP LUW, preferably in Azure DevOps or the established SAP CI/CD pipeline.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Service preview is unavailable | Confirm the binding is published and Gateway/ICF prerequisites are active. |
| No analyses appear | Confirm DCL owner isolation and the logon-user mapping. |
| Analyze is denied | Check `S_DEVELOP` change activity and behavior authorization. |
| Transport is reported missing | Use the request/task number exactly as stored in E070/E071. |
| Objects are missing from inventory | Check TADIR package assignment and deletion flag. |
| Import cannot deserialize an object type | Upgrade abapGit to a version supporting the RAP serializers used here. |

## Uninstall

Unpublish the service binding, remove launchpad content and role assignments, then uninstall the abapGit repository through the approved change process. Removing the persistence tables deletes analysis history; export required audit evidence first.
