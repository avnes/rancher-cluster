# rancher-cluster

# :warning: Repository not maintained :warning:

Please note that this repository is currently archived, and is no longer being maintained.

- It may contain code, or reference dependencies, with known vulnerabilities
- It may contain out-dated advice, how-to's or other forms of documentation

The contents might still serve as a source of inspiration, but please review any contents before reusing elsewhere.

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
