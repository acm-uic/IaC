#!/usr/bin/env bash
# Linux with unprivileged user namespaces, FRP binaries on PATH, curl, ip, openssl, Python 3.
set -euo pipefail
stack=$(cd "$(dirname "$0")/.." && pwd)
client=$(cd "$stack/../../../../kubernetes/argocd/umapyoi/frp-client" && pwd)
for binary in frps frpc; do
  command -v "$binary" >/dev/null
  [[ $("$binary" --version) == 0.72.0 ]] || { echo "Expected FRP 0.72.0" >&2; exit 1; }
done

# The published port numbers are safe to reuse inside this loopback-only network.
# The temporary /run and the processes disappear when the PID namespace exits.
unshare --user --map-root-user --mount --net --pid --fork --kill-child bash -se -- "$stack" "$client" <<'ISOLATED'
set -euo pipefail
mount --make-rprivate /
mount -t tmpfs tmpfs /run
ip link set lo up
umask 077
mkdir /run/{credentials,frp-trust,upstream}
cd /run
export FRP_ENABLE_SSH=false FRP_GATEWAY=tunnel.test FRP_INGRESS_SERVICE=127.0.0.1
export FRP_SSH_HOST='' FRP_SSH_PORT=22
FRP_AUTH_TOKEN=$(openssl rand -hex 32)
export FRP_AUTH_TOKEN
printf %s "$FRP_AUTH_TOKEN" > credentials/token

for name in tunnel.test one.test two.test; do
  openssl req -x509 -newkey rsa:2048 -nodes -days 1 -subj "/CN=$name" \
    -addext "subjectAltName=DNS:$name" -keyout "$name.key" -out "$name.crt" 2>/dev/null
done
cp tunnel.test.crt credentials/server.crt
cp tunnel.test.key credentials/server.key
cp tunnel.test.crt frp-trust/ca.crt
echo 'Umapyoi HTTP test' > upstream/index.html
python3 -m http.server 18080 --bind 127.0.0.1 --directory /run/upstream >http.log 2>&1 &
openssl s_server -accept 127.0.0.1:18443 -www -cert one.test.crt -key one.test.key \
  -cert2 two.test.crt -key2 two.test.key -servername two.test >https.log 2>&1 &

# The SNI/trust name stays tunnel.test. Replace DNS resolution and the two internal
# Service ports so the upstream fixture and gateway can share a network namespace.
sed -e 's/^serverAddr = .*/serverAddr = "127.0.0.1"/' \
    -e 's/^localPort = 80$/localPort = 18080/' -e 's/^localPort = 443$/localPort = 18443/' \
    "$2/frpc.toml" > client.toml
frps verify -c "$1/server/frps.toml"
frpc verify -c client.toml
frps -c "$1/server/frps.toml" >server.log 2>&1 &
server_pid=$!
frpc -c client.toml >client.log 2>&1 &
client_pid=$!

check_routes() {
  local address name
  for address in 127.0.0.1 '[::1]'; do
    for name in one.test two.test; do
      curl --noproxy '*' -fsS --max-time 3 --resolve "$name:80:$address" "http://$name/" |
        grep -qx 'Umapyoi HTTP test' || return 1
      curl --noproxy '*' -fsS --max-time 3 --resolve "$name:443:$address" \
        --cacert "$name.crt" "https://$name/" >/dev/null || return 1
    done
  done
}
wait_for_routes() {
  for attempt in {1..45}; do
    if check_routes 2>/dev/null; then return; fi
    sleep 1
  done
  tail -n 12 server.log client.log >&2
  return 1
}

wait_for_routes
kill "$server_pid"
wait "$server_pid" || true
frps -c "$1/server/frps.toml" >server.log 2>&1 &
wait_for_routes
kill "$client_pid"
wait "$client_pid" || true
frpc -c client.toml >client.log 2>&1 &
wait_for_routes
echo "Passed dual-stack HTTP, HTTPS with distinct SNI certificates, and both restart checks."
ISOLATED
