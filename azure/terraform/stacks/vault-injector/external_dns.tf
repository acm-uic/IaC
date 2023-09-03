resource "vault_kv_secret_v2" "externaldns_keyid" {
  mount = "kv"
  name  = "externaldns/service_account"
  data_json = jsonencode(
    {
      aadClientId     = data.terraform_remote_state.acm_general.outputs.externaldns_sp_appid,
      aadClientSecret = data.terraform_remote_state.acm_general.outputs.externaldns_sp_password
      resourceGroup   = data.terraform_remote_state.acm_general.outputs.default_resource_group
      subscriptionId  = data.terraform_remote_state.acm_general.outputs.subscription_id
      tenantId        = data.terraform_remote_state.acm_general.outputs.tenant_id
    }
  )
  custom_metadata {
    data = {
      managed_by = "Terraform",
      repo       = "IaC/azure/terraform/stacks/vault-injector"
    }
  }
}
