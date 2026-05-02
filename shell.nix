with import <nixpkgs> { };

mkShell {
  name = "ACM IaC";
  packages = [
    # terraform # Will compile from source.
    ansible
    kubectl
    bootc
    podman
    vault-bin
    pssh
    sops
    consul-template
  ];

  shellHook = ''
      export KUBECONFIG="$PWD/k8s-kubeconfig";
      export VAULT_ADDR="https://vault.acmuic.org"
      export VAULT_SKIP_VERIFY="true"
  '';
}
