#!/usr/bin/env python3
"""
Generate a client infrastructure repo from this cookiecutter template.

Usage:
    python generate.py                                          # uses client_config.contoso.json
    python generate.py --config client_config.acme.json         # uses a different config
    python generate.py --config client_config.contoso.json --overwrite

The config file should contain all cookiecutter context values.
See client_config.contoso.json for the expected format.

Any value not provided in the config file (or via CLI flags) will fall back
to the defaults defined in DEFAULTS below.
"""

import argparse
import json
import os
import shutil
import sys
from pathlib import Path

from cookiecutter.main import cookiecutter

# ---------------------------------------------------------------------------
# Defaults – override per-client via config file or CLI flags
# These only cover top-level cookiecutter vars. env_to_region_map comes
# entirely from the config file.
# ---------------------------------------------------------------------------
DEFAULTS = {
    "project_slug": "alz-{client_name}-adp-infra",
    "client_name": "contoso",
    "tenant_id": "00000000-0000-0000-0000-000000000000",
    "subscription_id": "00000000-0000-0000-0000-000000000000",
    "state_resource_group": "rg-{client_name}-state",
    "state_storage_account": "st{client_name}state",
    "state_container": "tfstate",
}


def resolve_defaults(context: dict) -> dict:
    """Merge provided context over DEFAULTS and interpolate {client_name} placeholders."""
    merged = {**DEFAULTS, **context}

    client_name = merged["client_name"]

    # Interpolate {client_name} in string values
    for key, value in merged.items():
        if isinstance(value, str) and "{client_name}" in value:
            merged[key] = value.format(client_name=client_name)

    return merged


def main():
    parser = argparse.ArgumentParser(
        description="Generate a client infrastructure repo from the ADP environment template."
    )
    parser.add_argument(
        "--config",
        default="client_config.contoso.json",
        help="Path to a JSON config file with cookiecutter context values (default: client_config.contoso.json).",
    )
    parser.add_argument(
        "--output-dir",
        default="./output",
        help="Directory where the generated project will be placed (default: ./output).",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite the output directory if it already exists.",
    )

    # Convenience CLI flags for common overrides
    parser.add_argument("--client-name", help="Client name (used in slug and resource names).")
    parser.add_argument("--tenant-id", help="Azure tenant ID.")
    parser.add_argument("--subscription-id", help="Azure subscription ID.")
    parser.add_argument("--state-resource-group", help="Terraform state resource group.")
    parser.add_argument("--state-storage-account", help="Terraform state storage account.")
    parser.add_argument("--state-container", help="Terraform state container name.")

    args = parser.parse_args()

    # Load config file
    config_path = Path(args.config)
    if not config_path.is_file():
        print(f"Error: config file not found: {config_path}", file=sys.stderr)
        sys.exit(1)
    with open(config_path) as f:
        context = json.load(f)

    # CLI flags override config file values
    cli_overrides = {
        "client_name": args.client_name,
        "tenant_id": args.tenant_id,
        "subscription_id": args.subscription_id,
        "state_resource_group": args.state_resource_group,
        "state_storage_account": args.state_storage_account,
        "state_container": args.state_container,
    }
    for key, value in cli_overrides.items():
        if value is not None:
            context[key] = value

    # Merge with defaults
    context = resolve_defaults(context)

    # env_to_region_map must be passed as a JSON string to cookiecutter
    if "env_to_region_map" in context and isinstance(context["env_to_region_map"], dict):
        context["env_to_region_map"] = json.dumps(context["env_to_region_map"])

    # Template directory is the repo root (where this script lives)
    template_dir = str(Path(__file__).resolve().parent)

    project_slug = context.get("project_slug", "generated-project")
    target_dir = Path(args.output_dir) / project_slug

    # Clean up previous output so stale files don't linger
    if args.overwrite and target_dir.exists():
        def _force_remove_readonly(func, path, _exc_info):
            """Handle read-only files (e.g. .git/objects) on Windows."""
            os.chmod(path, 0o777)
            func(path)

        shutil.rmtree(target_dir, onexc=_force_remove_readonly)
        print(f"Cleaned up existing {target_dir}")

    print(f"Using config: {args.config}")
    print(f"Project slug: {project_slug}")

    cookiecutter(
        template_dir,
        no_input=True,
        extra_context=context,
        output_dir=args.output_dir,
        overwrite_if_exists=args.overwrite,
    )

    print(f"Generated at {target_dir}")


if __name__ == "__main__":
    main()

