# Maid Café guest inventory

This stack adopts the existing **30 QEMU VMs (including templates) and 16 LXC
containers**. Each guest has its own `<guest-name>.tf` file, preserving the
name's capitalization. The unnamed guests use Proxmox's display names:
`VM 104.tf`, `VM 105.tf` and `VM 106.tf`. The HA policy for `bootc-builder`
is kept alongside its VM definition. Shared imports, outputs and provider
configuration remain in their respective files. `horchata` currently has no guests.

Resource labels use the guest type and VMID rather than guest names.

Historical `k8s-02.tf.disable` through `k8s-08.tf.disable` are retained
for reference because they have no corresponding active guest file. Terraform
does not load these files. The old WiCyS disabled files are superseded by
`wicys-attack.tf` and `wicys-defend.tf`.

The inventory was read from Proxmox on 2026-10-15. Keep the VMID, guest type,
node, disk storage, MAC addresses, firmware and template flags aligned with the
actual guest when editing a definition. Renaming a resource label requires an
explicit state move; renaming a file does not change a resource's address.
Reusing a VMID does not transfer ownership to a new guest.

## Adoption and state migration

`imports.tf` adopts all 46 guests and the existing HA policy for `bootc-builder`
(VM 110). It also removes ownership of the stale
`proxmox_vm_qemu.k8s_01` address with **`destroy = false`**. That address actually
points to `matcha/qemu/107`, the existing `taskbox-template`, which is imported
as `proxmox_virtual_environment_vm.vm_107`.

The active provider is pinned to `bpg/proxmox` 0.116.1. Telmate 3.0.2-rc02 is
retained only to interpret and safely detach the legacy state entry. Do not
delete the `removed` block or the legacy provider until every workspace that
contains that entry has completed adoption. Do not restore an old state file
over the current guests or re-enable the historical Kubernetes/WiCyS definitions.

The initial adoption plan imports 47 objects and detaches the one legacy entry.
The 16 container updates initialize only Terraform metadata (`vm_id` and
`timeout_start`); they do not change guest configuration. Validation uses a
local copy of production state with API writes blocked.

The backend and workspace remain unchanged: Azure storage
`acmhybridstore/acm-terraform-state`, key `maid-cafe-k8s.tfstate`, workspace
`prod`. Adoption must use that workspace. Import blocks are idempotent and
may remain after adoption.

## Change safeguards

Every managed object has `prevent_destroy = true`. The plan policy also blocks
creation, deletion, replacement, forgetting state, guest ID/node changes, and SMBIOS UUID mismatches.
This second check matters because removing an entire resource definition also
removes its Terraform lifecycle guard.

The sole permitted state removal is the legacy 107 address, and only when the
same plan imports `matcha/107` at its new address. New guest creation or deliberate
decommissioning needs a separate reviewed policy/configuration change.

Power state (`started`) is operated in Proxmox and ignored by Terraform; importing
a stopped guest must not start it. Autostart flags are explicitly recorded and
remain managed. Existing descriptions/operator notes are preserved but not
published in this repository. Resource pools, templates, EFI/TPM disks, guest
disks, networks and the existing VM 110 HA policy are managed. Primary CD-ROM
drives, SMBIOS UUIDs, and TPM state omitted by the provider during import are
recorded but narrowly ignored to prevent redundant hardware writes during
adoption. Those peripherals remain operated in Proxmox until their state can be
accurately adopted. The provider supports one CD-ROM per VM; extra secondary ISO
drives are recorded in comments and remain operated in Proxmox.

For containers with no explicit `cpuunits`, the provider reads zero although
zero is not a valid configured weight. Only `cpu[0].units` is ignored for those
guests, preserving Proxmox's host default. The required container
`operating_system.template_file_id = ""` denotes import-only configuration,
an empty placeholder for the already-existing container; no creation image is selected.
No backup restore or guest creation is performed.

## Validation and application

The PR and apply workflows run formatting/validation, print the human-readable
plan in the job log while saving it, and check the plan policy. OpenTofu redacts
values marked sensitive in this log output. The saved plan and machine-readable
JSON contain credentials and guest metadata, so they remain private temporary
files and are never uploaded as artifacts or printed. The safety-check summary
is published in the job summary.

Application is **manual only** and applies the exact saved plan that passed the
policy. The incident-disabled apply workflow should remain disabled until this
PR is reviewed and merged. Re-enable and dispatch it only after reviewing a fresh
production plan; merging this PR alone must not apply anything.

Both workflows share a concurrency group. Required credentials are the existing
Azure backend environment variables and `TF_VAR_proxmox_api_token_id` /
`TF_VAR_proxmox_api_token_secret`. `configuration/prod.tfvars` supplies the API
URL, accepting the existing `/api2/json` suffix. Proxmox also requires
`VM.Config.Disk` for its disk metadata read endpoint.

For a private local plan, with backend and Proxmox credentials already configured:

```sh
umask 077
export TF_WORKSPACE=prod
tofu init -input=false
tofu validate
tofu plan -var-file=configuration/prod.tfvars -out=/private/path/maid-cafe.tfplan
tofu show -json /private/path/maid-cafe.tfplan > /private/path/maid-cafe.tfplan.json
python3 ../../../../.github/scripts/check_proxmox_plan.py /private/path/maid-cafe.tfplan.json
```

Do not commit state, plan files, API tokens, or raw API exports. The plan policy
has offline regression tests:

```sh
python3 -m unittest discover -s .github/scripts -p 'test_*.py'
```

Run that test command from the repository root.

## Current guests

| ID | Type | Node | Guest | Pool |
| --- | --- | --- | --- | --- |
| 100 | LXC | boba | [cafe-manager](<cafe-manager.tf>) | — |
| 101 | VM | boba | [lug-ctf-live-host](<lug-ctf-live-host.tf>) | — |
| 102 | VM | coffee | [samsCS468PleaseDontTouch](<samsCS468PleaseDontTouch.tf>) | — |
| 103 | LXC | boba | [mc-github-runner](<mc-github-runner.tf>) | — |
| 104 | VM | coffee | [VM 104 (template)](<VM 104.tf>) | — |
| 105 | VM | chai | [VM 105](<VM 105.tf>) | — |
| 106 | VM | boba | [VM 106](<VM 106.tf>) | — |
| 107 | VM | matcha | [taskbox-template (template)](<taskbox-template.tf>) | — |
| 108 | VM | matcha | [webserver-template (template)](<webserver-template.tf>) | — |
| 109 | VM | matcha | [db-template (template)](<db-template.tf>) | — |
| 110 | VM | boba | [bootc-builder](<bootc-builder.tf>) | Bootc |
| 111 | VM | matcha | [bootc-test](<bootc-test.tf>) | Bootc |
| 112 | VM | matcha | [pi-nas](<pi-nas.tf>) | — |
| 113 | VM | matcha | [death-to-ansible](<death-to-ansible.tf>) | — |
| 114 | LXC | chai | [ani-backend](<ani-backend.tf>) | — |
| 115 | VM | chai | [wicys-attack (template)](<wicys-attack.tf>) | — |
| 116 | VM | chai | [wicys-defend (template)](<wicys-defend.tf>) | — |
| 117 | LXC | chai | [ani-frontend](<ani-frontend.tf>) | — |
| 118 | LXC | chai | [ani-db](<ani-db.tf>) | — |
| 119 | LXC | chai | [lovebug](<lovebug.tf>) | — |
| 120 | LXC | coffee | [ansible-test1](<ansible-test1.tf>) | — |
| 121 | LXC | coffee | [ansible-test2](<ansible-test2.tf>) | — |
| 122 | LXC | boba | [sig-ai](<sig-ai.tf>) | — |
| 123 | LXC | boba | [lug-ctf](<lug-ctf.tf>) | — |
| 124 | LXC | coffee | [dd-clone-test](<dd-clone-test.tf>) | — |
| 125 | LXC | boba | [lug-cloudflared](<lug-cloudflared.tf>) | — |
| 126 | LXC | boba | [intotheflame](<intotheflame.tf>) | — |
| 127 | VM | matcha | [ad-template (template)](<ad-template.tf>) | — |
| 128 | VM | chai | [Samsvm2](<Samsvm2.tf>) | — |
| 129 | VM | chai | [bluetest](<bluetest.tf>) | — |
| 130 | LXC | boba | [bytetheflame](<bytetheflame.tf>) | — |
| 131 | LXC | boba | [weatherapp](<weatherapp.tf>) | — |
| 132 | VM | matcha | [fp-taskbox-01](<fp-taskbox-01.tf>) | FlamePenguins |
| 133 | VM | matcha | [fp-webserver-01](<fp-webserver-01.tf>) | FlamePenguins |
| 134 | VM | matcha | [fp-db-01](<fp-db-01.tf>) | FlamePenguins |
| 135 | VM | matcha | [fp-ad-01](<fp-ad-01.tf>) | FlamePenguins |
| 136 | VM | matcha | [bad-taskbox-01](<bad-taskbox-01.tf>) | 0xbadb002 |
| 137 | VM | matcha | [bad-webserver-01](<bad-webserver-01.tf>) | 0xbadb002 |
| 138 | VM | matcha | [bad-db-01](<bad-db-01.tf>) | 0xbadb002 |
| 139 | VM | matcha | [bad-ad-01](<bad-ad-01.tf>) | 0xbadb002 |
| 140 | VM | matcha | [bp-taskbox-01](<bp-taskbox-01.tf>) | ButterPizza |
| 141 | VM | matcha | [bp-webserver-01](<bp-webserver-01.tf>) | ButterPizza |
| 142 | VM | matcha | [bp-db-01](<bp-db-01.tf>) | ButterPizza |
| 143 | VM | matcha | [bp-ad-01](<bp-ad-01.tf>) | ButterPizza |
| 144 | VM | boba | [lug-ctf-workbench](<lug-ctf-workbench.tf>) | — |
| 167 | LXC | coffee | [rgw-proxy-1](<rgw-proxy-1.tf>) | — |
