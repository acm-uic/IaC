# Operating the Umapyoi gateway

## Service and tunnel health

Run the Azure commands from the initialized OpenTofu stack directory. The VM's public SSH port is closed by default. Operators authorized for Azure Run Command can execute the same host diagnostics without opening it. Run Command provides root-equivalent access.

```bash
vm_id=$(tofu output -raw vm_id)
az vm get-instance-view --ids "$vm_id" --query 'instanceView.statuses[].displayStatus' -o tsv
az vm run-command invoke --ids "$vm_id" --command-id RunShellScript --scripts \
  'cloud-init status --long; systemctl is-active frps; cd /opt/frp && docker compose ps; ip -6 addr show dev eth0; ip -6 route'
```

On the VM, use the following commands as root. The health endpoint and Prometheus metrics bind to loopback **inside the container**. No dashboard or metrics port is published. A healthy process and an open Docker port can coexist with a disconnected client. Check proxy registration and a real request as well. [FRP monitoring](https://gofrp.org/en/docs/features/common/monitor/)

```bash
cd /opt/frp
systemctl status frps --no-pager
journalctl -u frps --since '30 minutes ago' --no-pager
docker compose logs --since 30m frps
docker compose exec -T frps wget -qO- http://127.0.0.1:7501/healthz
docker compose exec -T frps wget -qO- http://127.0.0.1:7501/metrics
ss -lnt
```

On the operator machine, check the app revision, client logs and resource use. Look for a successful login and successful registration of **both** `umapyoi-http` and `umapyoi-https`. Repeated control connection errors or repeated logins in a short interval indicate tunnel flapping. Umapyoi runs metrics-server. Record `kubectl top` during representative traffic before increasing concurrency or changing limits. The process retries a disconnected tunnel internally. A connectivity-based liveness probe would interrupt that recovery.

```bash
kubectl --context admin@umapyoi -n argocd get application frp-client
kubectl --context admin@umapyoi -n frp-system get deploy,pods
kubectl --context admin@umapyoi -n frp-system logs deployment/frpc --since=30m
kubectl --context admin@umapyoi -n frp-system top pods
kubectl --context admin@umapyoi -n kube-system get svc cilium-ingress
kubectl --context admin@umapyoi get ingress,ciliumenvoyconfig,certificate,challenge -A
```

## Validate a cutover

1. Before assigning DNS ownership, export the two public IPs from OpenTofu. Use two approved application hostnames with distinct routes and an endpoint that identifies each application. From an external network with IPv4 and IPv6, run the following checks. Use public CA verification for application HTTPS. Replace the paths with application-specific health endpoints if needed.

   ```bash
   v4=$(tofu output -json public_addresses | jq -r .IPv4)
   v6=$(tofu output -json public_addresses | jq -r .IPv6)
   for host in "$APP_ONE" "$APP_TWO"; do
     curl -4 --show-error --resolve "$host:80:$v4" -i "http://$host/"
     curl -6 --show-error --resolve "$host:80:[$v6]" -i "http://$host/"
     curl -4 --show-error --resolve "$host:443:$v4" -i "https://$host/"
     curl -6 --show-error --resolve "$host:443:[$v6]" -i "https://$host/"
   done
   ```

2. Check each expected HTTP status/redirect, certificate SAN and application identity. Compare the external leaf fingerprint with the one served at the shared Cilium Service from an authorized in-cluster diagnostics pod. Specify the same application SNI in both `openssl s_client` calls. After cutover, check authoritative A and AAAA answers, repeat curl without `--resolve`, and observe a complete staging ACME challenge/issuance and subsequent renewal before marking certificate management verified.
3. From authorized and non-allowlisted test networks, verify the expected NSG outcomes separately for IPv4 and IPv6 using the known gateway IPs and only the configured service ports. Public 80/443 should reach Cilium, 7000 should accept only allowed site sources, and 22/2222 should be closed unless explicitly enabled. Verify the effective NIC NSG. The final inbound deny takes precedence over Azure's implicit VNet allowance.
4. From an authorized site source, verify tunnel TLS with `openssl s_client -connect tunnel.acmuic.org:7000 -servername tunnel.acmuic.org -verify_hostname tunnel.acmuic.org -verify_return_error -CAfile ca.crt </dev/null`. Track certificate expiry and issuer trust independently of application certificates. From both address families compare the external visitor address with the immediate downstream peer in Cilium/Hubble or an approved diagnostic backend. Record the observed peer and the application log's forwarding semantics. Client-supplied `X-Forwarded-For` is untrusted.
5. In an approved maintenance window, reboot the VM, observe cloud networking, systemd and proxy re-registration, and repeat the application checks. Restart the client pod separately, repeat the checks, and record recovery time. Confirm the on-premises firewall changed only outbound access if any change was necessary.

## Troubleshooting and recovery

| Observation | What to check |
| --- | --- |
| VM up, frps unavailable | Check `cloud-init status --long`, `/var/log/cloud-init-output.log`, `systemctl status frps` and Docker service status. Verify DNS/HTTPS egress to Ubuntu mirrors, GHCR and the vault. |
| Startup reports HTTP 403/404 | Confirm the secret exists, its current version is enabled, the VM identity has **Key Vault Secrets User on that secret**, and vault network rules allow the VM. Role propagation can take several minutes. Systemd retries automatically. Avoid printing the secret or IMDS response. |
| Client certificate error | Verify SAN, certificate dates, intermediate chain and mounted CA. If the tunnel hostname changes, update the certificate and `settings.env` together. If authentication fails after TLS succeeds, compare credential revisions and verify the token file has exactly 64 hexadecimal characters with no trailing newline. |
| TCP connects but no application responds | Docker can accept a public socket before the remote proxy is registered. Check both FRP logs, internal DNS, the shared Ingress annotation, Envoy listener and backend endpoints. A Cilium 404 typically indicates an unmatched route. |
| IPv4 works, IPv6 fails | Check the authoritative AAAA address, NIC IPv6 allocation, IPv6 NSG rule and VNet /64. Inspect DHCPv6 and the default route on eth0. The default Docker IPv4 bridge relies on Docker's enabled userland proxy to publish its ports on host IPv6. Test from a genuine external IPv6 network. [Docker port publishing](https://docs.docker.com/engine/network/port-publishing/) |
| Logs repeat disconnects | Check site NAT/firewall idle timeouts, VM CPU credits, packet loss, memory pressure and client pod evictions. Compare external probes to FRP login and registration times. |
| Container exits | Systemd restarts the Compose stack and retrieves the current bundle. On demand use `systemctl restart frps`. For a client process crash, kubelet restarts the container and frpc reconnects. |

## Rotation, updates and rollback

- **Client configuration.** Update `settings.env` or `frpc.toml` in Git. Kustomize changes the generated ConfigMap name in the pod template. Run the gateway plan/deploy workflow for the reviewed commit. Argo reconciles a single-replica Recreate rollout. Expect a short interruption. Roll back by reverting the change and deploying the revert commit.
- **Token.** Stage an immutable Secret under a new revision on Umapyoi, with the new token and current trust chain. Publish the matching server bundle as a new version in Key Vault, restart `frps.service`, and change the `&credentials` name in `deployment.yaml` to the staged revision. Deploy that commit with the gateway workflow to roll out the client. Coordinate the cutover because FRP accepts one token at a time. Retain the old Secret and vault version until traffic passes, then retire them under the organization's retention policy.
- **Transport certificate.** For the same CA, publish the renewed leaf, its matching private key and current token as a new bundle version and restart frps. For a CA change, first roll the client to a new immutable Secret containing both roots. Switch the server certificate, test, then remove the retiring root in another client revision. Keep the CA signing key offline. Restore a prior known-good bundle as a **new latest version** during rollback and revert the client Secret reference if needed.
- **Server updates.** Treat the VM as replaceable. Edit the pinned image digest/configuration in `server/`, or change the pinned Ubuntu image version, then plan and review the VM replacement. Bootstrap files are part of `custom_data`. The stable NIC, public IPs, vault secret and user-assigned identity survive the VM replacement. Schedule downtime, apply the reviewed plan, and verify both application hostnames and address families. Revert and reapply the last working configuration for a rollback. Keep the two FRP versions compatible during staged upgrades. Secret rotation requires only a service restart. [FRP releases](https://github.com/fatedier/frp/releases)
- **Emergency withdrawal.** Revert application DNS to the previous endpoint if applicable. For immediate containment, stop the gateway service or withdraw the public web allow rules in a reviewed infrastructure change. Removing a DNS record alone leaves the published IP reachable. Restore and validate the on-premises entrypoint before directing clients back to it.

## Original IP and optional SSH

FRP 0.72 supports `transport.proxyProtocolVersion = "v2"` on a TCP proxy. Umapyoi's Cilium 1.20.4 ingress and Gateway API PROXY settings are disabled. Cilium's ingress-wide switch requires PROXY input on every affected listener. The shared Service also accepts plain traffic, and Docker's IPv6-to-IPv4 userland proxy may already substitute the peer on the Azure side. A future preservation design needs an address-preserving gateway path, a dedicated trusted ingress listener isolated to frpc, and IPv4/IPv6 tests for direct and tunneled clients. Leave PROXY disabled on the shared path. [FRP real client IP](https://gofrp.org/en/docs/features/common/realip/) · [Cilium 1.20.4 Helm values](https://github.com/cilium/cilium/blob/v1.20.4/install/kubernetes/cilium/values.yaml)

To enable SSH after web cutover, verify the destination administrator has approved the target, enabled public-key authentication, disabled password and keyboard-interactive authentication, and supplied the SSH host-key fingerprint over a trusted channel. Set `source_cidrs.forwarded_ssh` to the allowed administrator sources. OpenTofu enables the matching NSG rules, Compose publication and frps port allowance. Review the resulting VM replacement. Set `FRP_SSH_HOST` and `FRP_SSH_PORT` to the approved reachable host or Service in `settings.env`. From an allowed source verify the known host key and a key-authenticated login with `ssh -o BatchMode=yes -o StrictHostKeyChecking=yes -p 2222 user@tunnel.acmuic.org`. Verify refusal from a disallowed source and test each permitted family. To withdraw, remove the client target and return the OpenTofu source list to empty. VM administration on TCP 22 has its own separate allowlist.
