#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import os
from datetime import datetime
from typing import Dict, List, Any

from azure.identity import AzureCliCredential
from azure.mgmt.resource import ResourceManagementClient


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="List Azure resources (Python Azure SDK).")
    p.add_argument("--subscription-id", required=True, help="Azure subscription ID")
    p.add_argument("--rg-prefix", default="rg-aruop-dev", help="Resource group name prefix to include")
    p.add_argument("--include-mc", action="store_true", help="Include AKS managed resource groups (MC_*)")
    p.add_argument("--out-dir", default=".", help="Output directory for CSV/JSON")
    return p.parse_args()


def rg_in_scope(rg_name: str, rg_prefix: str, include_mc: bool) -> bool:
    if rg_name.startswith(rg_prefix):
        return True
    if include_mc and rg_name.startswith("MC_"):
        return True
    return False


def safe_mkdir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def print_table(rows: List[Dict[str, Any]]) -> None:
    # Lightweight console table (no extra deps).
    cols = ["resourceGroup", "type", "name", "location"]
    widths = {c: len(c) for c in cols}
    for r in rows:
        for c in cols:
            widths[c] = max(widths[c], len(str(r.get(c, ""))))

    header = " | ".join(c.ljust(widths[c]) for c in cols)
    sep = "-+-".join("-" * widths[c] for c in cols)
    print(header)
    print(sep)
    for r in rows:
        line = " | ".join(str(r.get(c, "")).ljust(widths[c]) for c in cols)
        print(line)


def main() -> int:
    args = parse_args()

    # Uses current "az login" session.
    credential = AzureCliCredential()
    client = ResourceManagementClient(credential, args.subscription_id)

    # Select resource groups in scope
    rgs = [rg.name for rg in client.resource_groups.list() if rg_in_scope(rg.name, args.rg_prefix, args.include_mc)]
    rgs.sort()

    all_rows: List[Dict[str, Any]] = []
    for rg_name in rgs:
        for res in client.resources.list_by_resource_group(rg_name):
            all_rows.append(
                {
                    "resourceGroup": rg_name,
                    "name": res.name,
                    "type": res.type,
                    "location": getattr(res, "location", "") or "",
                    "id": res.id,
                }
            )

    # Sort for stable output
    all_rows.sort(key=lambda x: (x["resourceGroup"], x["type"], x["name"]))

    # Output
    print(f"Subscription: {args.subscription_id}")
    print(f"Resource groups matched: {len(rgs)}")
    print(f"Resources found: {len(all_rows)}\n")

    print_table(all_rows)

    safe_mkdir(args.out_dir)
    stamp = datetime.utcnow().strftime("%Y%m%d-%H%M%SZ")
    csv_path = os.path.join(args.out_dir, f"azure-resources-{stamp}.csv")
    json_path = os.path.join(args.out_dir, f"azure-resources-{stamp}.json")

    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["resourceGroup", "type", "name", "location", "id"])
        w.writeheader()
        w.writerows(all_rows)

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(
            {
                "subscriptionId": args.subscription_id,
                "resourceGroups": rgs,
                "count": len(all_rows),
                "resources": all_rows,
            },
            f,
            indent=2,
        )

    print(f"\nSaved CSV : {csv_path}")
    print(f"Saved JSON: {json_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
