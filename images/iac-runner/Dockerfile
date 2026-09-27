# Job container for IaC workflows on the acmapp-k8s scale set.
# The scale set pod stays on ghcr.io/actions/actions-runner. This image
# adds the CLIs those workflows call inside the job container.
FROM ghcr.io/actions/actions-runner:latest

USER root

# CI stacks pin Terraform 1.9.8. Maid café does not pin OpenTofu.
ARG TERRAFORM_VERSION=1.9.8
ARG OPENTOFU_VERSION=1.12.6
ARG KUBE_LINTER_VERSION=0.8.3

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        jq \
        lsb-release \
        unzip \
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip \
    && unzip -jo /tmp/terraform.zip -d /usr/local/bin \
    && curl -fsSL "https://github.com/opentofu/opentofu/releases/download/v${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION}_linux_amd64.zip" -o /tmp/tofu.zip \
    && unzip -jo /tmp/tofu.zip tofu -d /usr/local/bin \
    && curl -fsSL "https://github.com/stackrox/kube-linter/releases/download/v${KUBE_LINTER_VERSION}/kube-linter-linux" -o /usr/local/bin/kube-linter \
    && chmod 755 /usr/local/bin/terraform /usr/local/bin/tofu /usr/local/bin/kube-linter \
    && rm -rf /tmp/terraform.zip /tmp/tofu.zip /var/lib/apt/lists/*

USER runner
