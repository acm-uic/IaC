# Umapyoi FRP gateway

One Ubuntu 24.04 VM in North Central US forwards TCP 80 and 443 over an outbound FRP tunnel to `cilium-ingress.kube-system.svc.cluster.local` on Umapyoi. Cilium terminates each application's TLS session. A separate TLS connection authenticates the gateway to frpc using the configured tunnel CA and DNS name. FRP authenticates the client with a 256-bit shared token.

The [deployment results](VALIDATION.md) distinguish local traffic tests, live read-only checks, and outstanding public tests. The [monthly estimate](COST.md) is $13.64 in fixed retail charges before usage. Use the [operations guide](OPERATIONS.md) for upgrades, rotation and cutover checks.

## Before deployment

- Review the plan, the on-premises NAT egress addresses, application exposure, and the original-IP limitation below. Obtain authorization before applying resources, activating the Argo application, or writing DNS. The **Umapyoi public gateway** workflow controls both the Terraform apply and the Argo CD Application. Merging changes makes them available for a deployment.
- Umapyoi has an IPv4-only Cilium Service. An IPv4 outbound control connection can serve visitors on both public address families. Obtain the site's actual public IPv4 NAT address from the network operator. Use a /32 or the smallest authorized prefix. Add IPv6 control sources only if the site can originate those connections. Egress must allow TCP 7000 to the gateway and cluster DNS. No inbound on-premises firewall rule is needed.
- Verify the selected subscription and the `admin@umapyoi` context. The operator needs access to the existing state container using Entra ID (Storage Blob Data Contributor), permission to deploy the new resource group and assign a role on the existing vault secret. The issuer of the tunnel certificate and the operator who seeds the bundle can be separate identities. Register Microsoft.Compute, Network, ManagedIdentity and KeyVault in advance. Optional billing alerts require Microsoft.Consumption and an eligible subscription.
- Review every Cilium Ingress using the shared listener. Anyone reaching the gateway can supply any Host header or SNI, including names without public DNS. Use dedicated Ingresses for internal-only services. Each public application needs an explicit shared Ingress and a working certificate. At inspection time Umapyoi had no application Ingress, Gateway, HTTPRoute, Issuer or ClusterIssuer.
- Accept the visitor-IP limitation before cutover. The ingress sees a cluster-side peer. Rate limits, audit rules and IP allowlists based on visitor addresses require separate design. A token holder can register an allowed port when it is free and receive traffic intended for it. The VM and its administrators can see plaintext HTTP, connection metadata and the tunnel credentials. The application TLS private keys stay with Cilium. The pod can reach destinations permitted by cluster egress policy. Its supplied NetworkPolicy denies incoming connections.

## Stage credentials

Use a private directory outside the checkout, preferably on a protected temporary filesystem. Obtain a server certificate with a DNS SAN for the gateway hostname, a matching unencrypted leaf private key for unattended startup, and the trust root. Keep the CA signing key with its issuer. Supply intermediates after the leaf in `server.crt`. Use a dedicated tunnel credential for this site.

The commands below assume Bash, jq, OpenSSL, Azure CLI and kubectl. Run them only after provisioning is authorized. Set `FRP_CREDENTIALS` to the absolute path of the protected directory containing `server.crt`, `server.key` and `ca.crt`. Run from the repository root.

```bash
set -euo pipefail
umask 077
cd "${FRP_CREDENTIALS:?set the protected credential directory}"
openssl x509 -in server.crt -noout -checkhost tunnel.acmuic.org
# For an intermediate CA, also pass -untrusted intermediates.pem.
openssl verify -purpose sslserver -verify_hostname tunnel.acmuic.org -CAfile ca.crt server.crt
diff <(openssl x509 -in server.crt -pubkey -noout) <(openssl pkey -in server.key -pubout)

# First issuance only. Retain the token for certificate-only rotation.
( set -o noclobber; printf %s "$(openssl rand -hex 32)" > token )
jq -n --rawfile token token --rawfile cert server.crt --rawfile key server.key \
  '{token:$token,"server.crt":$cert,"server.key":$key}' > server-bundle.json
az keyvault secret set --vault-name black-book --name umapyoi-frps \
  --file server-bundle.json --output none
cd -
```

The VM's user-assigned identity can read this single, pre-existing secret. Its startup unit reads the current version via IMDS and the Key Vault HTTPS API, then writes group-readable files underneath a root-only directory in `/run`. Terraform, cloud-init, Docker environment variables and the cluster never receive the server private key. Azure Run Command and host root are privileged management paths. [Azure Key Vault RBAC scopes](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide)

Umapyoi had no secret-sync operator at inspection. Stage the client token and CA as a single immutable, revision-named Secret. Creation fails on a name collision. Choose a new revision for each rotation. The Deployment references that revision for both values. Protect Kubernetes Secret read privileges and verify the cluster's encryption-at-rest configuration. [Kubernetes immutable Secrets](https://kubernetes.io/docs/concepts/configuration/secret/#immutable-secrets)

```bash
client=kubernetes/argocd/umapyoi/frp-client
kubectl --context admin@umapyoi apply -f "$client/namespace.yaml"
kubectl --context admin@umapyoi -n frp-system create secret generic frp-client-auth-v1 \
  --from-file=token="$FRP_CREDENTIALS/token" --from-file=ca.crt="$FRP_CREDENTIALS/ca.crt" \
  --dry-run=client -o json | jq '.immutable = true' | kubectl --context admin@umapyoi create -f -
```

## Deploy with GitHub Actions

Use **Actions → Umapyoi public gateway → Run workflow** on `main`. Pull requests from repository branches validate Terraform and render the Kustomize client on `acmapp-builder`. Manual plan and apply jobs use the same runner pool and the existing `prod` GitHub environment. After a successful apply, `acmapp-k8s` publishes the Argo CD Application to Umapyoi. Both runner pools use the repository's IaC job container.

Configure these settings before the first run.

| GitHub setting | Value |
| --- | --- |
| Existing Azure OIDC secrets | `AZURE_AD_CLIENT_ID`, `AZURE_AD_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`. The federated credential must accept the repository's `environment:prod` subject. Grant the identity the state-container and Azure resource permissions listed above. |
| `prod` variable `UMAPYOI_GATEWAY_TFVARS_JSON` | A Terraform JSON variable object containing the VM administrator's **public** SSH key and the actual site egress CIDRs. It also accepts the stack's optional settings, including explicitly approved DNS records. A plan uses the values available when it runs. |
| `prod` secret `UMAPYOI_DEPLOY_KUBECONFIG` | A self-contained kubeconfig in YAML for a dedicated Umapyoi deployment identity. Name the context `umapyoi-deploy`, embed the cluster CA, and use an API endpoint reachable from `acmapp-k8s`. Bind a namespaced Role in `argocd` with API group `argoproj.io`, resource `applications`, `resourceNames: ["frp-client"]`, and verbs `get`, `patch`, `create` (first server-side apply). Stage the FRP Secret separately. |

The minimum tfvars JSON has this shape. Replace both placeholders with real inputs.

```json
{
  "admin_ssh_public_key": "ssh-ed25519 REPLACE_WITH_PUBLIC_KEY",
  "source_cidrs": { "control": ["192.0.2.10/32"] }
}
```

1. Stage the credentials above and review the client settings, CA hostname, monthly cost and network ranges. Select **plan**. The workflow saves a distinct binary plan in the private state container, scoped to the checked-out commit. The run summary lists the changed resources, the plan ID and the exact blob name.
2. Review the full plan with the runner's Terraform version (currently 1.9.8). From the checked-out gateway stack directory and with a state-container reader identity, use the commands below. Store the downloaded file in a private temporary directory and remove it after review.
3. After approval, select **deploy** on `main` and enter that plan ID. Terraform applies the saved plan in the `prod` workspace. A different main commit requires a new plan, and Terraform rejects a stale state snapshot. A successful apply removes the saved blob. Delete superseded or abandoned plan blobs by their exact names.
4. The client job applies the Argo Application at the **same commit**. It waits for Argo to report that revision Synced and Healthy. For a client-only deployment, review and deploy the no-change Terraform plan. If the client job fails after a successful Terraform apply, fix the cluster issue and choose **Re-run failed jobs** for that deployment run. Confirm proxy registration and public traffic with the [operations checks](OPERATIONS.md).

```bash
umask 077
plan_dir=$(mktemp -d)
az storage blob download --auth-mode login --account-name acmhybridstore \
  --container-name acm-terraform-state --name "$PLAN_BLOB_FROM_RUN_SUMMARY" \
  --file "$plan_dir/gateway.tfplan" --output none
terraform init -backend=false -lockfile=readonly
terraform show -no-color "$plan_dir/gateway.tfplan"
rm -f -- "$plan_dir/gateway.tfplan"
rmdir -- "$plan_dir"
```

The encrypted Azure Blob backend uses the organization's existing account and container, a separate state key, Entra ID data-plane access and blob leasing. The stack uses a static public address of each family, one NIC and a Standard SSD E4 OS disk. The NIC NSG filters IPv4 and IPv6 separately and denies remaining inbound traffic, including traffic from the VNet. The VM receives its initial configuration through cloud-init. Systemd supervises Docker Compose, checks the server's loopback health endpoint and retries if identity permissions have not yet propagated. [Azure dual-stack VM](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/create-vm-dual-stack-ipv6-portal) · [Terraform Azure backend](https://developer.hashicorp.com/terraform/language/backend/azurerm)

## Route applications and verify cutover

1. After DNS authorization, publish A and AAAA records for `tunnel.acmuic.org` using the public addresses in the Terraform apply job outputs. For Azure DNS in `acm-general`, enable the commented `dns` object and include the label `tunnel`. Add approved application labels later. Check existing record ownership, CNAMEs and any external-dns TXT ownership before assigning Terraform ownership. External providers can publish the same address pair. Keep one owner per record set.
2. Configure the application's own Ingress with `spec.ingressClassName: cilium`, `ingress.cilium.io/loadbalancer-mode: shared`, its backend Service and a TLS Secret covering its host. Umapyoi's default Ingress mode is dedicated. A dedicated Ingress or a Gateway API listener has a different frontend. Verify that Cilium generates an Envoy configuration referencing the shared Service. Its synthetic EndpointSlice and empty external LoadBalancer status are expected on this path. frpc uses its ClusterIP.
3. Choose the application's issuer with its owner. For cert-manager HTTP-01, use `http01.ingress.ingressClassName: cilium` and add `ingress.cilium.io/loadbalancer-mode: shared` to the solver's `ingressTemplate.metadata.annotations`. Validate the challenge path and any redirect on both families using a staging issuer before production issuance. DNS-01 needs a working authoritative DNS solver and a successful TXT challenge. Keep application certificate issuance, storage and renewals in the cluster. [Cilium Ingress modes](https://docs.cilium.io/en/stable/network/servicemesh/ingress/) · [cert-manager HTTP-01 configuration](https://cert-manager.io/docs/configuration/acme/http01/)
4. Review `settings.env` and the credential revision in the [Umapyoi manifests](../../../../kubernetes/argocd/umapyoi/frp-client/). The gateway setting must match the server certificate SAN. The deployment workflow applies `frp-client/application.yaml` directly to the existing Umapyoi Argo CD controller. Argo continually reconciles the client at the deployed commit. Kustomize hashes both configuration ConfigMaps, and the Deployment's Recreate strategy avoids overlapping remote registrations. A container exit is restarted by Kubernetes. A network interruption is retried inside frpc.
5. Verify at least two real application routes with forced DNS resolution before moving existing traffic. This check needs a valid application certificate. For first-time HTTP-01 issuance, authorize a canary hostname, publish both records for it and complete staging issuance before moving an existing hostname. Publish application A and AAAA records under their existing DNS ownership, then repeat the checks through normal DNS. See [acceptance and recovery commands](OPERATIONS.md).

### Shared Cilium route example

In the application's namespace, repeat this pattern for each approved host and replace the example Service, port and TLS Secret with the application's resources. The TLS Secret contains the application certificate. The tunnel certificate is independent.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: public-web
  annotations:
    ingress.cilium.io/loadbalancer-mode: shared
spec:
  ingressClassName: cilium
  tls:
    - hosts: [app.example.org]
      secretName: public-web-tls
  rules:
    - host: app.example.org
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 80
```
