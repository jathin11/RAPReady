#!/usr/bin/env python3
"""Validate the repository shape without pretending to run an SAP syntax check."""

from __future__ import annotations

import json
import sys
import xml.etree.ElementTree as element_tree
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def validate_xml() -> None:
    for path in ROOT.rglob("*.xml"):
        try:
            element_tree.parse(path)
        except element_tree.ParseError as error:
            fail(f"invalid XML in {path.relative_to(ROOT)}: {error}")


def validate_baseinfo() -> None:
    for path in SRC.rglob("*.ddls.baseinfo"):
        try:
            payload = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as error:
            fail(f"invalid JSON in {path.name}: {error}")
        if "BASEINFO" not in payload:
            fail(f"missing BASEINFO root in {path.name}")


def validate_pairs() -> None:
    pairs = {
        ".clas.abap": ".clas.xml",
        ".intf.abap": ".intf.xml",
        ".ddls.asddls": ".ddls.xml",
        ".ddlx.asddlxs": ".ddlx.xml",
        ".dcls.asdcls": ".dcls.xml",
        ".bdef.asbdef": ".bdef.xml",
        ".srvd.srvdsrv": ".srvd.xml",
    }
    for source_suffix, metadata_suffix in pairs.items():
        for source in SRC.rglob(f"*{source_suffix}"):
            metadata = source.with_name(
                source.name[: -len(source_suffix)] + metadata_suffix
            )
            if not metadata.exists():
                fail(f"missing serializer metadata {metadata.name}")


def require_hardening_controls() -> None:
    required = [
        SRC / "adapter" / "package.devc.xml",
        SRC / "adapter" / "zcl_rr_repo_onprem.clas.abap",
        SRC / "zc_rr_analysis.dcls.asdcls",
        SRC / "zc_rr_finding.dcls.asdcls",
        SRC / "zc_rr_object.dcls.asdcls",
        SRC / "z_rapready.suso.xml",
        SRC / "zrrp.susc.xml",
    ]
    for path in required:
        if not path.exists():
            fail(f"missing production control {path.relative_to(ROOT)}")

    analyzer = (SRC / "zcl_rr_analyzer.clas.abap").read_text(encoding="utf-8")
    if "CLEAR: et_objects, et_findings." not in analyzer:
        fail("analyzer outputs are not explicitly cleared")

    behavior = (SRC / "zr_rr_analysis.bdef.asbdef").read_text(encoding="utf-8")
    if "authorization master ( global, instance )" not in behavior:
        fail("instance authorization is not enabled")
    if "field ( features : instance ) ScopePackage, TransportRequest" not in behavior:
        fail("analysis inputs are not state protected")

    adapter = SRC / "adapter" / "zcl_rr_repo_onprem.clas.abap"
    if not adapter.exists():
        fail("classic SAP dependencies are not isolated in the adapter subpackage")


def main() -> None:
    validate_xml()
    validate_baseinfo()
    validate_pairs()
    require_hardening_controls()
    print("Repository serialization and hardening checks passed.")
    print("SAP activation, ABAP Unit, ATC, DCL and OData tests remain external gates.")


if __name__ == "__main__":
    main()
