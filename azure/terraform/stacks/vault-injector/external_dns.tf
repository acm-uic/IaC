resource "vault_kv_secret_v2" "externaldns_keyid" {
  mount                      = "kv"
  name                       = "externaldns/service_account"
  data_json                  = jsonencode(
  {
    key_id = data.terraform_remote_state.acm_general.outputs.externaldns_sp_keyid,
    key_secret = data.terraform_remote_state.acm_general.outputs.externaldns_sp_password
  }
  )
  custom_metadata {
    data = {
      managed_by = "Terraform",
      repo = "IaC/azure/terraform/stacks/vault-injector"
    }
  }
}
