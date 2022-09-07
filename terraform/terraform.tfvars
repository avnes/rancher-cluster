github_owner             = "avnes"
github_repository_name   = "rke-setting"
rke_cluster_name         = "cowboy"
rke_kubernetes_version   = "v1.24.2-rancher1-1"
rke_enable_cri_dockerd   = true
rke_ssh_key_path         = "~/.ssh/rancher.pem"
rancher_ingress_hostname = "rancher-lb"
rke_node_username        = "ansible"
rke_nodes = [
  {
    internal_address = "10.0.1.40"
    address          = "rancher-controlplane"
    role             = ["controlplane", "etcd"]
  },
  {
    internal_address = "10.0.1.41"
    address          = "rancher-node01"
    role             = ["worker"]
  },
  {
    internal_address = "10.0.1.42"
    address          = "rancher-node02"
    role             = ["worker"]
  },
  {
    internal_address = "10.0.1.43"
    address          = "rancher-node03"
    role             = ["worker"]
  },
]
