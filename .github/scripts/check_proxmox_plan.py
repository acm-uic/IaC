#!/usr/bin/env python3
"""Reject destructive guest plans, including removal of lifecycle guards."""

import argparse
import json
import sys
from collections import Counter


# The only reviewed new guest. Never reuse the legacy Telmate address/VMID 107.
K8S_01_IDENTITY = {
    "vm_id": 168,
    "node_name": "boba",
    "name": "k8s-01",
    "started": False,
    "template": False,
    "protection": True,
}


def check_plan(plan):
    errors = []
    counts = Counter()
    imports = 0
    changes = plan.get("resource_changes", [])
    adopted_template = any(
        change["address"] == "proxmox_virtual_environment_vm.vm_107"
        and (change.get("change", {}).get("importing") or {}).get("id") == "matcha/107"
        for change in changes
    )
    for resource in changes:
        if resource.get("mode", "managed") != "managed":
            continue
        change = resource["change"]
        actions = change["actions"]
        address = resource["address"]
        counts.update(actions)
        imports += bool(change.get("importing"))

        # The one legacy state entry refers to taskbox-template, not k8s-01.
        # Permit forgetting it only when that same guest is being imported.
        legacy_detach = (
            address == "proxmox_vm_qemu.k8s_01"
            and actions == ["forget"]
            and (change.get("before") or {}).get("id") == "matcha/qemu/107"
            and adopted_template
        )
        after, unknown = change.get("after") or {}, change.get("after_unknown") or {}
        new_k8s = (
            address == "proxmox_virtual_environment_vm.k8s_01"
            and resource.get("type") == "proxmox_virtual_environment_vm"
            and actions == ["create"]
            and change.get("before") is None
            and not change.get("importing")
            and all(after.get(field) == value and not unknown.get(field)
                    for field, value in K8S_01_IDENTITY.items())
        )
        if any(action in actions for action in ("create", "delete", "forget")) and not (legacy_detach or new_k8s):
            errors.append(f"{address}: rejected actions {actions}")
        if actions == ["update"]:
            before, after = change.get("before") or {}, change.get("after") or {}
            unknown = change.get("after_unknown") or {}
            # Container imports expose id immediately but initialize the optional
            # vm_id attribute from configuration. This is state metadata only.
            imported_container_id = (
                resource.get("type") == "proxmox_virtual_environment_container"
                and before.get("vm_id") is None
                and before.get("id") == str(after.get("vm_id"))
                and not unknown.get("vm_id")
                and (change.get("importing") or {}).get("id")
                == f"{after.get('node_name')}/{after.get('vm_id')}"
            )
            for field in ("id", "vm_id", "node_name", "vmid", "target_node"):
                if field == "vm_id" and imported_container_id:
                    continue
                if field in before and (unknown.get(field) or before[field] != after.get(field)):
                    errors.append(f"{address}: guest identity/placement change in {field}")
            old_smbios, new_smbios = before.get("smbios") or [], after.get("smbios") or []
            if old_smbios and new_smbios:
                old_uuid, new_uuid = old_smbios[0].get("uuid"), new_smbios[0].get("uuid")
                if old_uuid and new_uuid and old_uuid != new_uuid:
                    errors.append(f"{address}: SMBIOS UUID mismatch; the VMID may have been reused")

    return errors, counts, imports


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("plan", help="Output of tofu show -json for the saved plan")
    args = parser.parse_args()
    with open(args.plan, encoding="utf-8") as source:
        plan = json.load(source)
    errors, counts, imports = check_plan(plan)
    print("### Proxmox plan safety check\n")
    print(f"Imports: {imports}; creates: {counts['create']}; updates: {counts['update']}; unchanged: {counts['no-op']}.")
    updates = [resource for resource in plan.get("resource_changes", [])
               if resource["change"]["actions"] == ["update"]]
    if updates:
        print("\n| Resource | Changed attributes |\n| --- | --- |")
        for resource in updates:
            change = resource["change"]
            before, after = change.get("before") or {}, change.get("after") or {}
            fields = sorted(key for key in set(before) | set(after) if before.get(key) != after.get(key))
            print(f"| {resource['address']} | {', '.join(fields)} |")
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    if counts["create"]:
        print("Approved creation: k8s-01 (VM 168 on boba), initially stopped.")
    print("No unapproved guest creation, deletion, replacement, or identity changes are planned.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
