output "kubeconfig" {
  value     = rke_cluster.cluster.kube_config_yaml
  sensitive = true
}

output "save_kubeconfig" {
  value = "terraform output kubeconfig | grep -v EOT > ${local.kubeconfig_path} && export KUBECONFIG=${local.kubeconfig_path}"
}

output "rancher_dashboard" {
  value = "Rancher Dashboard: ${local.rke_api_url}/dashboard"
}

output "rancher_username" {
  value = "Rancher username: ${rancher2_bootstrap.bootstrap.user}"
}

output "rancher_password" {
  value     = "Rancher password: ${rancher2_bootstrap.bootstrap.current_password}"
  sensitive = true
}
