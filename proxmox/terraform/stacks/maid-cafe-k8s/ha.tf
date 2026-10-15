# Preserve the existing HA policy for the running bootc builder.
resource "proxmox_haresource" "bootc_builder" {
  resource_id  = "vm:110"
  state        = "started"
  max_restart  = 10
  max_relocate = 0

  lifecycle {
    prevent_destroy = true
  }
}
