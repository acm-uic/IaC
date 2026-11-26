"""Fetch one coherent server credential version before Compose starts."""
import json
import os
import re
import urllib.parse
import urllib.request
from pathlib import Path

opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))


def read_json(url, headers):
    request = urllib.request.Request(url, headers=headers)
    with opener.open(request, timeout=15) as response:
        return json.load(response)


def main():
    query = urllib.parse.urlencode({
        "api-version": "2018-02-01",
        "resource": "https://vault.azure.net",
        "client_id": os.environ["AZURE_CLIENT_ID"],
    })
    identity = read_json(
        "http://169.254.169.254/metadata/identity/oauth2/token?" + query,
        {"Metadata": "true"},
    )
    response = read_json(
        os.environ["FRP_BUNDLE_URL"] + "?api-version=7.4",
        {"Authorization": "Bearer " + identity["access_token"]},
    )
    bundle = json.loads(response["value"])
    if not re.fullmatch(r"[0-9a-fA-F]{64}", bundle["token"]):
        raise ValueError("Expected a 256-bit hexadecimal FRP token")

    directory = Path("/run/frp-gateway/credentials")
    directory.mkdir(exist_ok=True)
    os.chown(directory, 0, 65532)
    directory.chmod(0o750)
    for name in ("token", "server.crt", "server.key"):
        path = directory / name
        path.write_text(bundle[name], encoding="utf-8")
        os.chown(path, 0, 65532)
        path.chmod(0o440)


if __name__ == "__main__":
    main()
