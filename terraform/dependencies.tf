locals {
  rke_api_url     = "https://${var.rancher_ingress_hostname}"
  kubeconfig_path = pathexpand("~/.kube/${var.rke_cluster_name}.config")
}
