# Use the actual public key and the site's observed NAT egress address(es).
# Set TF_VAR_admin_ssh_public_key from a public-key file (see README).
source_cidrs = {
  control = ["192.0.2.10/32"]
  # vm_ssh        = ["198.51.100.42/32"]
  # forwarded_ssh = ["198.51.100.42/32"]
}

# Enable only when the records are approved and ownership is clear.
# dns = { zone = "acmuic.org", resource_group = "acm-general", labels = ["tunnel"] }
# budget = { amount = 15, start_date = "2026-11-01T00:00:00Z", emails = ["ops@example.org"] }
