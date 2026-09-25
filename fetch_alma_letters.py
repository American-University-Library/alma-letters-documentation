"""
Alma Letters Exporter

Retrieves Alma letter configuration through the read-only Configuration API
and exports letter templates for Git-based version control.

Also produces:
    documentation/letter-inventory.json
        Machine-readable export record.
    documentation/default_snapshots/<LetterCode>_Default.xsl
        Historical baseline of each letter's default XSL, retained across runs
        so customized letters can be diffed against the Alma default.
    documentation/deviation_report.md
        Human-readable deviation report. One row per letter.

Required environment variable:
    ALMA_API_KEY

Required Alma permissions:
    Configuration -> Production -> Read-only

Alma endpoints used:
    GET /almaws/v1/conf/letters
    GET /almaws/v1/conf/letters/{letterCode}
"""

import difflib
import hashlib
import json
import os
import re
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import requests


# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

BASE_URL = "https://api-na.hosted.exlibrisgroup.com"
REQUEST_TIMEOUT = 30
REQUEST_DELAY = 0.5

PROJECT_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = PROJECT_DIR / "Alma Letters"
DOCUMENTATION_DIR = PROJECT_DIR / "documentation"
SNAPSHOT_DIR = DOCUMENTATION_DIR / "default_snapshots"
INVENTORY_PATH = DOCUMENTATION_DIR / "letter-inventory.json"
DEVIATION_REPORT_PATH = DOCUMENTATION_DIR / "deviation_report.md"

API_KEY = os.environ.get("ALMA_API_KEY")

if not API_KEY:
    raise RuntimeError(
        "ALMA_API_KEY is not set. Add it to PyCharm Environment variables "
        "or set it in the current PowerShell session before running."
    )

HEADERS = {
    "Authorization": f"apikey {API_KEY}",
    "Accept": "application/json",
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
# API helpers
# ---------------------------------------------------------------------------

def request_json(url: str) -> dict:
    """Make a read-only Alma API request and return parsed JSON."""
    response = requests.get(
        url,
        headers=HEADERS,
        timeout=REQUEST_TIMEOUT,
    )
    response.raise_for_status()

    try:
        return response.json()
    except ValueError as exc:
        content_type = response.headers.get("Content-Type", "")
        raise RuntimeError(
            f"Expected JSON but received Content-Type: {content_type}"
        ) from exc


def fetch_all_letters() -> list[dict]:
    """Retrieve the list of Alma letters."""
    data = request_json(f"{BASE_URL}/almaws/v1/conf/letters")

    letters = data.get("letter", [])

    if not isinstance(letters, list):
        raise RuntimeError(
            "Unexpected response structure from the Alma letter-list API. "
            f"Top-level response keys: {list(data.keys())}"
        )

    return letters


def fetch_letter_detail(letter_code: str) -> dict:
    """Retrieve the detail record and XSL content for one Alma letter."""
    return request_json(
        f"{BASE_URL}/almaws/v1/conf/letters/{letter_code}"
    )


# ---------------------------------------------------------------------------
# File and data helpers
# ---------------------------------------------------------------------------

def sanitize_filename(name: str) -> str:
    """Convert an Alma letter name into a Windows-safe filename."""
    name = (name or "").strip()
    name = name.replace("/", "-").replace("\\", "-")
    name = re.sub(r'[<>:"|?*]', "", name)
    name = re.sub(r"\s+", " ", name)
    name = name.strip(" .")

    return name or "unnamed_letter"


def is_true(value) -> bool:
    """Convert Alma textual Boolean values to a Python Boolean."""
    return str(value).strip().lower() == "true"


def build_filename(letter_name: str, customized: bool) -> str:
    """
    Apply repository naming convention.

    Default letter:
        Analytics Letter_Default.xsl

    Customized letter:
        Analytics Letter.xsl
    """
    base = sanitize_filename(letter_name)

    if customized:
        return f"{base}.xsl"

    return f"{base}_Default.xsl"


def sha256_text(text: str) -> str:
    """Return a SHA-256 digest for a text payload."""
    return hashlib.sha256(
        text.encode("utf-8")
    ).hexdigest()


def snapshot_path_for(letter_code: str) -> Path:
    """Location of the retained default-XSL snapshot for a letter code."""
    return SNAPSHOT_DIR / f"{sanitize_filename(letter_code)}_Default.xsl"


def load_snapshot(letter_code: str) -> str | None:
    """Return the retained default XSL for a letter, or None if absent."""
    path = snapshot_path_for(letter_code)

    if not path.is_file():
        return None

    return path.read_text(encoding="utf-8")


def save_snapshot(letter_code: str, xsl_content: str) -> None:
    """Persist the current default XSL as the baseline for future runs."""
    snapshot_path_for(letter_code).write_text(
        xsl_content,
        encoding="utf-8",
        newline="\n",
    )


def diff_summary(default_xsl: str, customized_xsl: str) -> str:
    """
    Produce a short, evidence-based description of how a customized letter
    deviates from the retained default snapshot.

    This is intentionally descriptive, not interpretive. It reports what
    changed and by how much. A human reviewer fills in the 'why' in the
    Reviewer Notes column.
    """
    if default_xsl == customized_xsl:
        return "Customized but identical to default snapshot (no XSL diff)."

    default_lines = default_xsl.splitlines()
    customized_lines = customized_xsl.splitlines()

    added = 0
    removed = 0

    for line in difflib.unified_diff(
        default_lines,
        customized_lines,
        lineterm="",
        n=0,
    ):
        if line.startswith("+++") or line.startswith("---") or line.startswith("@@"):
            continue
        if line.startswith("+"):
            added += 1
        elif line.startswith("-"):
            removed += 1

    size_delta = len(customized_xsl) - len(default_xsl)
    delta_sign = "+" if size_delta >= 0 else "-"

    parts = [
        "XSL differs from default snapshot.",
        f"{added} line(s) added, {removed} line(s) removed.",
        f"Size delta {delta_sign}{abs(size_delta)} bytes.",
    ]

    # Try to surface the first meaningful changed line as a pointer.
    for line in difflib.unified_diff(
        default_lines,
        customized_lines,
        lineterm="",
        n=0,
    ):
        if line.startswith(("+++", "---", "@@")):
            continue
        if line.startswith(("+", "-")):
            preview = line[1:].strip()
            if preview:
                parts.append(f"First change: {preview[:120]}")
                break

    return " ".join(parts)


def build_deviation_row(
    letter_code: str,
    letter_name: str,
    customized: bool,
    last_updated: str,
    default_xsl: str | None,
    current_xsl: str,
) -> list[str]:
    """Construct one row for the deviation report table."""
    if not customized:
        if default_xsl is None:
            description = "Default letter exported; baseline snapshot created."
        elif default_xsl == current_xsl:
            description = "Default letter unchanged since last snapshot."
        else:
            description = (
                "Default letter changed since last snapshot. "
                "Alma default was updated by the network zone."
            )
    else:
        if default_xsl is None:
            description = (
                "Customized letter. No default snapshot available for "
                "comparison; baseline unknown."
            )
        else:
            description = diff_summary(default_xsl, current_xsl)

    return [
        letter_code,
        letter_name,
        "Yes" if customized else "No",
        last_updated or "",
        description,
        "",  # Reviewer Notes, filled in by a human
    ]


def escape_markdown_cell(value: str) -> str:
    """Escape pipe characters so table cells render correctly."""
    return str(value).replace("|", "\\|").replace("\n", " ").strip()


def write_deviation_report(rows: list[list[str]], exported_at: str) -> None:
    """Write the deviation report as a Markdown table."""
    lines = [
        "# Alma Letters Deviation Report",
        "",
        f"- Generated (UTC): {exported_at}",
        f"- Alma base URL: {BASE_URL}",
        "- Managed by: WRLC network zone",
        "",
        "Deviations are computed against the retained default snapshot in",
        "`documentation/default_snapshots/`. The `Reviewer Notes` column is",
        "intentionally left blank for human documentation of the reason for",
        "each customization.",
        "",
        "| " + " | ".join(DEVIATION_REPORT_COLUMNS) + " |",
        "|" + "|".join(["---"] * len(DEVIATION_REPORT_COLUMNS)) + "|",
    ]

    for row in rows:
        lines.append(
            "| "
            + " | ".join(escape_markdown_cell(cell) for cell in row)
            + " |"
        )

    DEVIATION_REPORT_PATH.write_text(
        "\n".join(lines) + "\n",
        encoding="utf-8",
        newline="\n",
    )


# ---------------------------------------------------------------------------
# Main export
# ---------------------------------------------------------------------------

def main():
    OUTPUT_DIR.mkdir(exist_ok=True)
    DOCUMENTATION_DIR.mkdir(exist_ok=True)
    SNAPSHOT_DIR.mkdir(exist_ok=True)

    exported_at = datetime.now(timezone.utc).isoformat()

    try:
        letters = fetch_all_letters()
    except requests.HTTPError as exc:
        response = exc.response
        status = response.status_code if response is not None else "unknown"
        print(
            f"ERROR: Could not retrieve the Alma letter list. HTTP {status}.",
            file=sys.stderr,
        )
        sys.exit(1)
    except requests.RequestException as exc:
        print(
            f"ERROR: Request failed while retrieving the letter list: {exc}",
            file=sys.stderr,
        )
        sys.exit(1)

    print(f"Retrieved {len(letters)} letters from Alma.")

    inventory = {
        "exported_at_utc": exported_at,
        "alma_base_url": BASE_URL,
        "letter_count_returned": len(letters),
        "letters_exported": [],
        "letters_skipped": [],
    }

    deviation_rows: list[list[str]] = []

    exported_count = 0
    skipped_count = 0

    for index, letter in enumerate(letters, start=1):
        letter_code = (letter.get("code") or "").strip()

        if not letter_code:
            skipped_count += 1
            inventory["letters_skipped"].append({
                "reason": "List response did not include a letter code",
                "list_item": letter,
            })
            print(f"[{index}/{len(letters)}] SKIP: Missing letter code")
            continue

        print(
            f"[{index}/{len(letters)}] Retrieving {letter_code} ...",
            end=" ",
            flush=True,
        )

        try:
            detail = fetch_letter_detail(letter_code)
        except requests.HTTPError as exc:
            response = exc.response
            status = response.status_code if response is not None else "unknown"

            skipped_count += 1
            inventory["letters_skipped"].append({
                "code": letter_code,
                "reason": f"HTTP {status} while retrieving letter detail",
            })
            print(f"SKIP (HTTP {status})")
            time.sleep(REQUEST_DELAY)
            continue

        except requests.RequestException as exc:
            skipped_count += 1
            inventory["letters_skipped"].append({
                "code": letter_code,
                "reason": f"Request failed: {str(exc)}",
            })
            print("SKIP (request failed)")
            time.sleep(REQUEST_DELAY)
            continue

        letter_name = (
            detail.get("name")
            or letter.get("name")
            or letter_code
        )

        customized = is_true(
            detail.get("customized", {}).get("value", False)
        )

        xsl_content = detail.get("xsl", "")

        if not isinstance(xsl_content, str) or not xsl_content.strip():
            skipped_count += 1
            inventory["letters_skipped"].append({
                "code": letter_code,
                "name": letter_name,
                "reason": "No XSL content in detail response",
                "detail_keys": list(detail.keys()),
            })
            print("SKIP (no XSL content)")
            time.sleep(REQUEST_DELAY)
            continue

        # Load the retained default baseline before we overwrite anything.
        default_snapshot = load_snapshot(letter_code)

        # A default letter defines the baseline. Save it for future diffs.
        if not customized:
            save_snapshot(letter_code, xsl_content)

        filename = build_filename(letter_name, customized)
        output_path = OUTPUT_DIR / filename

        output_path.write_text(
            xsl_content,
            encoding="utf-8",
            newline="\n",
        )

        inventory["letters_exported"].append({
            "code": letter_code,
            "name": letter_name,
            "customized": customized,
            "enabled": detail.get("enabled", {}).get("value"),
            "channel": detail.get("channel"),
            "patron_facing": detail.get("patron_facing", {}).get("value"),
            "alma_updated_by": detail.get("updated_by", {}).get("value"),
            "alma_update_date": detail.get("update_date"),
            "file": str(output_path.relative_to(PROJECT_DIR)),
            "sha256": sha256_text(xsl_content),
            "has_default_snapshot": default_snapshot is not None,
        })

        deviation_rows.append(
            build_deviation_row(
                letter_code=letter_code,
                letter_name=letter_name,
                customized=customized,
                last_updated=detail.get("update_date") or "",
                default_xsl=default_snapshot,
                current_xsl=xsl_content,
            )
        )

        exported_count += 1
        print(f"SAVED ({filename})")

        time.sleep(REQUEST_DELAY)

    INVENTORY_PATH.write_text(
        json.dumps(inventory, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
        newline="\n",
    )

    deviation_rows.sort(key=lambda row: row[0].lower())
    write_deviation_report(deviation_rows, exported_at)

    print("\n" + "=" * 60)
    print("EXPORT SUMMARY")
    print("=" * 60)
    print(f"Letters returned by Alma : {len(letters)}")
    print(f"Templates exported       : {exported_count}")
    print(f"Letters skipped          : {skipped_count}")
    print(f"Template folder          : {OUTPUT_DIR}")
    print(f"Inventory file           : {INVENTORY_PATH}")
    print(f"Deviation report         : {DEVIATION_REPORT_PATH}")


if __name__ == "__main__":
    main()