# ACM member portal Terraform stack

Entra app registration for the member portal, plus the `portal-secrets` Kubernetes Secret (`BETTER_AUTH_SECRET` and `MICROSOFT_*`).

Helm / Argo CD deploy the app from `kubernetes/argocd/stacks/acm-member-portal`. SMTP, Discord, and Windows API keys are not managed here. Add them to the same Secret after apply. `kubernetes_secret_v1` replaces the whole object, so those extra keys are wiped on the next apply or client-secret rotation. Re-add them, or move them to a second Secret.

## Requirements

- Azure login with permission to create app registrations (`az login`, or the CI OIDC service principal)
- `KUBE_CONFIG_PATH` or `KUBECONFIG` pointing at the cluster that hosts `acm-portal`
- Namespace `acm-portal` already present (Argo CD creates it)

## Manual run

```bash
terraform init
terraform workspace select prod || terraform workspace new prod
terraform plan -var-file configuration/prod.tfvars
terraform apply -var-file configuration/prod.tfvars
```

After apply, in Entra: App registrations → `acm-member-portal-prod` → API permissions → Grant admin consent.
