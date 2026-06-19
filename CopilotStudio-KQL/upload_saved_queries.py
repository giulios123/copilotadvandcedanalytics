#!/usr/bin/env python3
"""Upload all .kql files in CopilotStudio-KQL as saved queries to Azure Monitor query packs."""

import argparse
import json
import os
import subprocess
import sys
import uuid
from pathlib import Path
from typing import Optional


REPO_ROOT = Path(__file__).resolve().parent.parent
KQL_ROOT = Path(__file__).resolve().parent
DEFAULT_QUERY_PACK = "CopilotStudioKQL-Queries"


def run(cmd: list[str], check: bool = True) -> subprocess.CompletedProcess:
    print("$", " ".join(cmd))
    return subprocess.run(cmd, text=True, capture_output=True, check=check)


def get_current_azure_context(subscription_id: Optional[str] = None) -> dict:
    """Use the current or explicitly requested Azure CLI account and an existing resource group."""
    show_cmd = ["az", "account", "show", "--output", "json"]
    if subscription_id:
        show_cmd.extend(["--subscription", subscription_id])

    account = json.loads(run(show_cmd, check=True).stdout)

    group_cmd = ["az", "group", "list", "--output", "json"]
    if subscription_id:
        group_cmd.extend(["--subscription", subscription_id])

    resource_groups = json.loads(run(group_cmd, check=True).stdout)

    if not resource_groups:
        raise RuntimeError("No resource groups were found in the selected Azure subscription.")

    return {
        "subscription_id": account["id"],
        "subscription_name": account.get("name", account["id"]),
        "resource_group": resource_groups[0]["name"],
    }


def ensure_query_pack(name: str, resource_group: str, subscription_id: str) -> None:
    cmd = [
        "az", "monitor", "log-analytics", "query-pack", "show",
        "--name", name,
        "--resource-group", resource_group,
        "--subscription", subscription_id,
    ]
    try:
        run(cmd, check=True)
        print(f"Query pack '{name}' already exists.")
    except subprocess.CalledProcessError as exc:
        if exc.returncode != 0:
            create_cmd = [
                "az", "monitor", "log-analytics", "query-pack", "create",
                "--name", name,
                "--resource-group", resource_group,
                "--subscription", subscription_id,
            ]
            run(create_cmd, check=True)
            print(f"Created query pack '{name}'.")


def upload_query(file_path: Path, query_pack_name: str, resource_group: str, subscription_id: str) -> None:
    body = file_path.read_text(encoding="utf-8")
    display_name = file_path.stem.replace("_", " ")
    description = f"Imported from {file_path.relative_to(KQL_ROOT)}"
    query_id = str(uuid.uuid5(uuid.NAMESPACE_URL, str(file_path.resolve())))

    cmd = [
        "az", "monitor", "log-analytics", "query-pack", "query", "create",
        "--query-id", query_id,
        "--display-name", display_name,
        "--description", description,
        "--resource-group", resource_group,
        "--query-pack-name", query_pack_name,
        "--subscription", subscription_id,
        "--body", body,
        "--categories", "[monitor]",
        "--resource-types", "[microsoft.insights/components]",
        "--solutions", "[logmanagement]",
        "--tags", "{source:[copilotstudio-kql],folder:[" + str(file_path.parent.name) + "]}",
    ]
    run(cmd, check=True)
    print(f"Uploaded: {file_path.relative_to(KQL_ROOT)}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Upload CopilotStudio KQL files as Azure Monitor saved queries")
    parser.add_argument("--query-pack-name", default=os.environ.get("QUERY_PACK_NAME", DEFAULT_QUERY_PACK))
    parser.add_argument("--resource-group", default=os.environ.get("RESOURCE_GROUP"))
    parser.add_argument("--subscription-id", default=os.environ.get("SUBSCRIPTION_ID"))
    args = parser.parse_args()

    try:
        context = get_current_azure_context(args.subscription_id)
        resource_group = args.resource_group or context["resource_group"]
        subscription_id = args.subscription_id or context["subscription_id"]
    except RuntimeError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        sys.exit(1)

    print(f"Using subscription: {subscription_id}")
    print(f"Using resource group: {resource_group}")
    print(f"Using query pack: {args.query_pack_name}")

    ensure_query_pack(args.query_pack_name, resource_group, subscription_id)

    kql_files = sorted(KQL_ROOT.rglob("*.kql"))
    if not kql_files:
        print("No .kql files found under CopilotStudio-KQL.", file=sys.stderr)
        sys.exit(1)

    for file_path in kql_files:
        upload_query(file_path, args.query_pack_name, resource_group, subscription_id)

    print("\nUpload complete.")


if __name__ == "__main__":
    main()
