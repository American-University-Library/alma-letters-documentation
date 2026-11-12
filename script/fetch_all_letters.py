"""
Alma Letters Exporter

Exports Alma letter XSL templates from sandbox, production, or both.

Required environment variables:
    ALMA_SANDBOX_API_KEY
        Required when exporting sandbox.

    ALMA_PRODUCTION_API_KEY
        Required when exporting production.

Each key must have Configuration API read-only access for its intended
environment and institution/network-zone context.

Examples:
    python fetch_alma_letters.py --environment sandbox
    python fetch_alma_letters.py --environment production
    python fetch_alma_letters.py --environment both

    python fetch_alma_letters.py --environment sandbox \
        --codes AnalyticsLetter BorrowerOverdueEmailLetter

    python fetch_alma_letters.py --environment both \
        --codes-file letter_codes.txt

Outputs:
    Alma Letters/<environment>/*.xsl
    documentation/<environment>/letter-inventory.json
    documentation/<environment>/default_snapshots/*.xsl
    documentation/<environment>/deviation_report.md

Only GET requests are made. This script does not update Alma.

Existing files for unselected letters are not deleted.
Inventory and deviation reports describe the current run only.
Reviewer Notes in the generated report are blank on every run.
"""

import argparse
import difflib
import hashlib
import json
import os
import re
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import quote

import requests


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BASE_URL = "https://api-na.hosted.exlibrisgroup.com"
REQUEST_TIMEOUT = 30
REQUEST_DELAY = 0.5

PROJECT_DIR = Path(__file__).resolve().parent

ENVIRONMENT_KEY_VARIABLES = {
    "sandbox": "ALMA_SANDBOX_API_KEY",
    "production": "ALMA_PRODUCTION_API_KEY",
}

DEVIATION_REPORT_COLUMNS = [
    "Letter Code",
    "Name",
    "Customized",
    "Last Updated",
    "Deviation Description",
    "Reviewer Notes",
]


# ---------------------------------------------------------------------------
# Arguments and letter selection
# ---------------------------------------------------------------------------

def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Export Alma letters from sandbox, production, or both."
    )

    parser.add_argument(
        "--environment",
        required=True,
        choices=["sandbox", "production", "both"],
        help="Environment to export. The corresponding API key must be set.",
    )

    selection = parser.add_mutually_exclusive_group()

    selection.add_argument(
        "--codes",
        nargs="+",
        metavar="LETTER_CODE",
        help="Exact Alma letter codes, separated by spaces.",
    )

    selection.add_argument(
        "--codes-file",
        type=Path,
        metavar="PATH",
        help=(
            "UTF-8 text file with one code per line. "
            "Blank lines and lines starting with # are ignored."
        ),
    )

    args = parser.parse_args()
    requested_codes = None

    if args.codes_file is not None:
        try:
            lines = args.codes_file.read_text(
                encoding="utf-8-sig"
            ).splitlines()
        except (OSError, UnicodeError) as exc:
            parser.error(f"Could not read letter-code file: {exc}")

        requested_codes = [
            line.strip()
            for line in lines
            if line.strip() and not line.strip().startswith("#")
        ]

    elif args.codes is not None:
        requested_codes = [
            code.strip()
            for code in args.codes
            if code.strip()
        ]

    if requested_codes is not None:
        requested_codes = list(dict.fromkeys(requested_codes))

        if not requested_codes:
            parser.error("Supply at least one nonblank letter code.")

    args.requested_codes = requested_codes
    return args


def select_letters(available_letters, requested_codes):
    if requested_codes is None:
        return available_letters

    available_by_code = {
        letter["code"]: letter
        for letter in available_letters
        if isinstance(letter.get("code"), str)
        and letter["code"].strip()
    }

    missing_codes = [
        code for code in requested_codes
        if code not in available_by_code
    ]

    if missing_codes:
        raise ValueError(
            "These codes were not returned by this environment: "
            + ", ".join(missing_codes)
            + ". Check spelling, capitalization, and API-key context."
        )

    return [available_by_code[code] for code in requested_codes]


# ---------------------------------------------------------------------------
# API helpers
# ---------------------------------------------------------------------------

def request_json(session, endpoint):
    response = session.get(
        f"{BASE_URL}{endpoint}",
        timeout=REQUEST_TIMEOUT,
    )

    if not response.ok:
        # Avoid logging request headers or credentials.
        raise RuntimeError(
            f"Alma returned HTTP {response.status_code} for {endpoint}."
        )

    try:
        data = response.json()
    except ValueError as exc:
        content_type = response.headers.get("Content-Type", "")
        raise RuntimeError(
            f"Expected JSON; received Content-Type: {content_type}"
        ) from exc

    if not isinstance(data, dict):
        raise RuntimeError("Expected a JSON object from Alma.")

    return data


def fetch_all_letters(session):
    data = request_json(session, "/almaws/v1/conf/letters")
    letters = data.get("letter")

    if not isinstance(letters, list):
        raise RuntimeError(
            "Unexpected letter-list structure. "
            f"Top-level keys: {list(data.keys())}"
        )

    if not all(isinstance(letter, dict) for letter in letters):
        raise RuntimeError("Letter list contains unexpected item types.")

    return letters


def fetch_letter_detail(session, letter_code):
    encoded_code = quote(letter_code, safe="")
    return request_json(
        session,
        f"/almaws/v1/conf/letters/{encoded_code}",
    )


# ---------------------------------------------------------------------------
# Files, metadata, and comparisons
# ---------------------------------------------------------------------------

def sanitize_filename(name):
    name = str(name or "").strip()
    name = name.replace("/", "-").replace("\\", "-")
    name = re.sub(r'[<>:"|?*\x00-\x1f]', "", name)
    name = re.sub(r"\s+", " ", name).strip(" .")

    if not name:
        return "unnamed_letter"

    reserved = {
        "CON", "PRN", "AUX", "NUL",
        *(f"COM{i}" for i in range(1, 10)),
        *(f"LPT{i}" for i in range(1, 10)),
    }

    if name.split(".")[0].upper() in reserved:
        name = "_" + name

    return name


def field_value(value):
    return value.get("value") if isinstance(value, dict) else value


def customization_status(detail):
    value = field_value(detail.get("customized"))

    if value is True or str(value).strip().lower() == "true":
        return True

    if value is False or str(value).strip().lower() == "false":
        return False

    raise ValueError("Missing or unrecognized customized indicator.")


def build_filename(letter_name, customized):
    base = sanitize_filename(letter_name)
    return f"{base}.xsl" if customized else f"{base}_Default.xsl"


def sha256_text(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def write_text(path, content):
    path.write_text(content, encoding="utf-8", newline="\n")


def diff_summary(default_xsl, current_xsl):
    if default_xsl == current_xsl:
        return "Customized but identical to retained snapshot."

    changes = list(difflib.unified_diff(
        default_xsl.splitlines(),
        current_xsl.splitlines(),
        lineterm="",
        n=0,
    ))

    added = 0
    removed = 0
    first_change = None

    for line in changes:
        if line.startswith(("+++", "---", "@@")):
            continue

        if line.startswith("+"):
            added += 1
        elif line.startswith("-"):
            removed += 1
        else:
            continue

        if first_change is None and line[1:].strip():
            first_change = line[1:].strip()[:120]

    size_delta = (
        len(current_xsl.encode("utf-8"))
        - len(default_xsl.encode("utf-8"))
    )

    description = (
        "XSL differs from retained snapshot. "
        f"{added} line(s) added, {removed} line(s) removed. "
        f"UTF-8 size delta {size_delta:+d} bytes."
    )

    if first_change:
        description += f" First change: {first_change}"

    return description


def build_deviation_row(
    code, name, customized, updated, previous_snapshot, current_xsl
):
    if customized:
        description = (
            "Customized letter. No retained non-customized snapshot "
            "available; baseline unknown."
            if previous_snapshot is None
            else diff_summary(previous_snapshot, current_xsl)
        )
    elif previous_snapshot is None:
        description = (
            "Non-customized letter exported; baseline snapshot created."
        )
    elif previous_snapshot == current_xsl:
        description = "Non-customized XSL unchanged since retained snapshot."
    else:
        description = (
            "Non-customized XSL changed since retained snapshot. "
            "Source of change requires review."
        )

    return [
        code, name, "Yes" if customized else "No",
        str(updated or ""), description, "",
    ]


def escape_markdown_cell(value):
    return (
        str(value)
        .replace("|", "\\|")
        .replace("\r", " ")
        .replace("\n", " ")
        .strip()
    )


def write_deviation_report(path, rows, exported_at, environment):
    lines = [
        "# Alma Letters Deviation Report",
        "",
        f"- Environment label: {environment}",
        f"- Generated (UTC): {exported_at}",
        f"- Alma base URL: {BASE_URL}",
        "- Source context: determined by the configured API key.",
        "",
        "Comparisons use retained non-customized XSL snapshots from this",
        "environment only. Snapshots are historical baselines, not proof",
        "of the latest original Ex Libris default.",
        "",
        "This report covers the current run only. Reviewer Notes are blank",
        "on generation; preserve human notes separately before rerunning.",
        "",
        "| " + " | ".join(DEVIATION_REPORT_COLUMNS) + " |",
        "|" + "|".join(["---"] * len(DEVIATION_REPORT_COLUMNS)) + "|",
    ]

    for row in sorted(rows, key=lambda item: item[0].lower()):
        lines.append(
            "| " + " | ".join(map(escape_markdown_cell, row)) + " |"
        )

    write_text(path, "\n".join(lines) + "\n")


# ---------------------------------------------------------------------------
# Environment-specific export
# ---------------------------------------------------------------------------

def export_environment(environment, api_key, requested_codes):
    output_dir = PROJECT_DIR / "Alma Letters" / environment
    documentation_dir = PROJECT_DIR / "documentation" / environment
    snapshot_dir = documentation_dir / "default_snapshots"
    inventory_path = documentation_dir / "letter-inventory.json"
    report_path = documentation_dir / "deviation_report.md"

    exported_at = datetime.now(timezone.utc).isoformat()

    print(f"\n=== {environment.upper()} EXPORT ===")
    print(
        "Source environment depends on the API key's configuration; "
        "the script cannot verify it from this label."
    )

    with requests.Session() as session:
        session.headers.update({
            "Authorization": f"apikey {api_key}",
            "Accept": "application/json",
        })

        available_letters = fetch_all_letters(session)
        letters = select_letters(available_letters, requested_codes)

        for directory in (output_dir, documentation_dir, snapshot_dir):
            directory.mkdir(parents=True, exist_ok=True)

        print(f"Available letters: {len(available_letters)}")
        print(f"Selected letters: {len(letters)}")

        inventory = {
            "exported_at_utc": exported_at,
            "environment_label": environment,
            "source_context": "Determined by configured API key",
            "alma_base_url": BASE_URL,
            "export_scope": (
                "selected_letters"
                if requested_codes is not None
                else "all_letters"
            ),
            "requested_codes": requested_codes,
            "letter_count_returned": len(available_letters),
            "letter_count_selected": len(letters),
            "letters_exported": [],
            "letters_skipped": [],
        }

        deviation_rows = []
        used_filenames = set()

        for index, letter in enumerate(letters, start=1):
            code = str(letter.get("code") or "").strip()

            print(
                f"[{environment} {index}/{len(letters)}] "
                f"{code or '(missing code)'} ... ",
                end="",
                flush=True,
            )

            try:
                if not code:
                    raise ValueError("Missing letter code.")

                detail = fetch_letter_detail(session, code)
                name = detail.get("name") or letter.get("name") or code
                customized = customization_status(detail)
                xsl_content = detail.get("xsl")

                if not isinstance(xsl_content, str) or not xsl_content.strip():
                    raise ValueError("No XSL content in detail response.")

                filename = build_filename(name, customized)

                if filename.casefold() in used_filenames:
                    raise ValueError(
                        f"Filename collision: {filename}. "
                        "Review display names before exporting."
                    )

                snapshot_path = (
                    snapshot_dir
                    / f"{sanitize_filename(code)}_Default.xsl"
                )

                previous_snapshot = (
                    snapshot_path.read_text(encoding="utf-8")
                    if snapshot_path.is_file()
                    else None
                )

                output_path = output_dir / filename
                write_text(output_path, xsl_content)

                if not customized:
                    write_text(snapshot_path, xsl_content)

                used_filenames.add(filename.casefold())

                inventory["letters_exported"].append({
                    "code": code,
                    "name": name,
                    "customized": customized,
                    "enabled": field_value(detail.get("enabled")),
                    "channel": detail.get("channel"),
                    "patron_facing": field_value(detail.get("patron_facing")),
                    "alma_updated_by": field_value(detail.get("updated_by")),
                    "alma_update_date": detail.get("update_date"),
                    "file": output_path.relative_to(PROJECT_DIR).as_posix(),
                    "sha256": sha256_text(xsl_content),
                    "had_default_snapshot_before_export": (
                        previous_snapshot is not None
                    ),
                    "has_default_snapshot": snapshot_path.is_file(),
                })

                deviation_rows.append(build_deviation_row(
                    code,
                    name,
                    customized,
                    detail.get("update_date"),
                    previous_snapshot,
                    xsl_content,
                ))

                print(f"SAVED ({filename})")

            except (
                requests.RequestException,
                RuntimeError,
                ValueError,
            ) as exc:
                reason = (
                    "Network request failed; check connectivity and retry."
                    if isinstance(exc, requests.RequestException)
                    else str(exc)
                )

                inventory["letters_skipped"].append({
                    "code": code,
                    "reason": reason,
                })
                print(f"SKIP ({reason})")

            time.sleep(REQUEST_DELAY)

    inventory["complete"] = not inventory["letters_skipped"]

    write_text(
        inventory_path,
        json.dumps(inventory, indent=2, ensure_ascii=False) + "\n",
    )

    write_deviation_report(
        report_path, deviation_rows, exported_at, environment
    )

    print(f"\n{environment.upper()} SUMMARY")
    print(f"Templates exported: {len(inventory['letters_exported'])}")
    print(f"Letters skipped:    {len(inventory['letters_skipped'])}")
    print(f"Template folder:    {output_dir}")
    print(f"Inventory:          {inventory_path}")
    print(f"Deviation report:   {report_path}")

    return inventory["complete"]


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    args = parse_arguments()

    environments = (
        ["sandbox", "production"]
        if args.environment == "both"
        else [args.environment]
    )

    keys = {}

    # Validate all requested credentials before making API calls.
    for environment in environments:
        variable = ENVIRONMENT_KEY_VARIABLES[environment]
        key = os.environ.get(variable, "").strip()

        if not key:
            print(
                f"ERROR: {variable} is not set.",
                file=sys.stderr,
            )
            return 1

        keys[environment] = key

    if len(keys) == 2 and keys["sandbox"] == keys["production"]:
        print(
            "ERROR: Sandbox and production keys are identical. "
            "Use separately configured keys and confirm their environments.",
            file=sys.stderr,
        )
        return 1

    complete = True

    for environment in environments:
        try:
            success = export_environment(
                environment,
                keys[environment],
                args.requested_codes,
            )
            complete = success and complete

        except (
            requests.RequestException,
            RuntimeError,
            ValueError,
            OSError,
        ) as exc:
            reason = (
                "Network request failed; check connectivity and retry."
                if isinstance(exc, requests.RequestException)
                else str(exc)
            )

            print(
                f"ERROR [{environment}]: {reason}",
                file=sys.stderr,
            )
            complete = False

    return 0 if complete else 1


if __name__ == "__main__":
    sys.exit(main())