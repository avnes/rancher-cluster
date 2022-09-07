# rancher-cluster

## Virtual server

It is provisionied using <https://github.com/avnes/rancher-vm>

## Install client tools

```bash
bin/01_install_cli_tools.sh
```

## Install RKE for Rancher

```bash
export TF_VAR_github_token=<REDACTED>
bin/02_create_cluster.sh
```
