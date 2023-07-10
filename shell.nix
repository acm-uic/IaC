with import <nixpkgs>{};

let PROJECT_ROOT=builtins.toString ./.; in
mkShell {
	name="ACM IaC";
	packages=[terraform ansible];


	KUBECONFIG="${PROJECT_ROOT}/k8s-kubeconfig";
}
