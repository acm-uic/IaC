#!/usr/bin/env python3
"""Summarize OpenTofu actions without restricting which changes may be applied."""

import argparse
import html
import json
from collections import Counter
from pathlib import Path


def summarize_plan(plan):
    counts = Counter()
    imports = 0
    rows = []
    for resource in plan.get("resource_changes", []):
        if resource.get("mode", "managed") != "managed":
            continue
        change = resource["change"]
        actions = change["actions"]
        counts.update(actions)
        imports += bool(change.get("importing"))
        if "create" in actions or "delete" in actions:
            # Resource addresses and action names are the only per-resource data
            # published. Never include before/after values or the raw plan JSON.
            address = html.escape(resource["address"]).replace("`", "&#96;").replace("|", "&#124;")
            address = " ".join(address.splitlines())
            action = "replace" if "create" in actions and "delete" in actions else actions[0]
            rows.append(f"| `{address}` | {action} |\n")

    summary = (
        "### OpenTofu plan summary\n\n"
        f"Imports: {imports}; creates: {counts['create']}; deletes: {counts['delete']}; "
        f"updates: {counts['update']}; forgets: {counts['forget']}; unchanged: {counts['no-op']}.\n\n"
    )
    if rows:
        summary += "Creations and deletions are informational and do not block deployment.\n\n"
        summary += "Replacements count as both a creation and a deletion.\n\n"
        summary += "| Resource | Action |\n| --- | --- |\n"
        # Leave room for the comment's header and run link below GitHub's limit.
        for index, row in enumerate(rows):
            if len(summary) + len(row) > 50000:
                summary += f"\n{len(rows) - index} additional resources omitted from this summary.\n"
                break
            summary += row
    else:
        summary += "No resource creations or deletions are planned.\n"
    return {"has_changes": bool(rows), "summary": summary}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("plan", type=Path, help="Output of tofu show -json for the saved plan")
    parser.add_argument("--report", type=Path, help="Write sanitized JSON for the PR comment")
    args = parser.parse_args(argv)
    with args.plan.open(encoding="utf-8") as source:
        report = summarize_plan(json.load(source))
    print(report["summary"], end="")
    if args.report:
        args.report.write_text(json.dumps(report), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
