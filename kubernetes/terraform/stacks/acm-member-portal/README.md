# ACM member portal Terraform stack

Entra app registration for the member portal, plus the `portal-secrets` Kubernetes Secret.

Terraform patches `BETTER_AUTH_SECRET` and `MICROSOFT_*`. Other keys (SMTP, Discord, Windows API) can live on the same Secret and are left alone on apply.

Helm / Argo CD deploy the app from `kubernetes/argocd/stacks/acm-member-portal`. If `portal-secrets` already exists, import the stub Secret before the first apply:

```bash
terraform import kubernetes_secret_v1.portal acm-portal/portal-secrets
```

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
