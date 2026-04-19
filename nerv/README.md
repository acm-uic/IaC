# Using bootable containers to build NERV HPC Cluster

## Semantics and Prerequisite Information

- Refer to [My Bootc Notes](https://sohamg.xyz/notes/bootc)

- Do not skip reading that!!

## Workflow

- Edit/Add files to ./etc or ./usr
  + Use drop-in directories like `foo.conf.d/` when possible.
  + /etc has higher priority in overrides, so use that.
  + Avoid writing/overwriting system files directly, do not touch /usr/bin,
    /usr/lib etc.

  
- Changes to OS through OS-native tooling like dnf packages etc go in
  Containerfile.

- Read comments in Containerfile and only make changes towards the end of the
  file. Do not make changes after etc and usr are copied.
  
- Make sure you can log in to a) the bootc-builder machine and b) the cluster
  nodes, both as root and without password (ssh, kerberos).
  
- Invoke `make latest`. This will build the image on the builder machine, push
  it to the azure registry, and trigger an update and reboot on the nodes.
  
- For testing, invoke `make test` which will make image with the tag `:test`
  which is running on VM `bootc-test`. Make sure to run `bootc upgrade &&
  reboot` on that VM for changes to take effect.
  
## Secrets

- Secrets are managed with [sops](https://github.com/getsops/sops). Familiarize
  with sops first.
  
- Key:Value pairs added to the nerv folder in Vault will automatically show up
  in crypt/enc.yml when refreshed.
  
- Make sure to run the appropriate `vault login` command to be able to access
  vault.
  
- Vault connection is only required at when **refreshing**. The vault dependency
  at runtime is purely optional, and lets you decrypt the file at any time thru
  vault as a convenience.
  
## General info

- Make sure any added script, service, program is idempotent.
- Use and abuse systemd.unit(5) and others for running scripts based on
  conditions like hostname, existence of files, etc.
- Use /var with care, since it is node-local and persistent. This means it also
  persists mistakes from past deplopyments.
- Use and abuse symlinks, wrapper scripts, oneshot services, and systemd unit
  overrides for maximum profit.
  
