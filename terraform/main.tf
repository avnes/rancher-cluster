# --------------------------------------------------
# GitHub
# --------------------------------------------------

provider "github" {
  owner = var.github_owner
  token = var.github_token
}

resource "github_repository" "main" {
  name                 = var.github_repository_name
  visibility           = var.github_repository_visibility
  vulnerability_alerts = var.github_vulnerability_alerts
  auto_init            = true
}

resource "github_branch_default" "main" {
  repository = github_repository.main.name
  branch     = var.github_repository_branch
}

resource "github_repository_file" "rke_kubeconfig" {
  repository = github_repository.main.name
  file       = var.rke_kubeconfig
  content    = rke_cluster.cluster.kube_config_yaml
  branch     = var.github_repository_branch
}

resource "github_repository_file" "rke_cluster_yaml" {
  repository = github_repository.main.name
  file       = var.rke_cluster_yaml
  content    = rke_cluster.cluster.rke_cluster_yaml
  branch     = var.github_repository_branch
}

resource "github_repository_file" "rke_statefile" {
  repository = github_repository.main.name
  file       = var.rke_statefile
  content    = rke_cluster.cluster.rke_state
  branch     = var.github_repository_branch
}

# --------------------------------------------------
# Rancher Kubernetes Engine (RKE)
# --------------------------------------------------

provider "rke" {
  debug    = var.rke_debug
  log_file = "provision.log"
}

resource "rke_cluster" "cluster" {
  cluster_name       = var.rke_cluster_name
  kubernetes_version = var.rke_kubernetes_version
  enable_cri_dockerd = var.rke_enable_cri_dockerd
  ssh_key_path       = "~/.ssh/id_rsa"
  ssh_agent_auth     = false

  dynamic "nodes" {
    for_each = var.rke_nodes
    content {
      internal_address = nodes.value["internal_address"]
      address          = nodes.value["address"]
      user             = var.rke_node_username
      role             = nodes.value["role"]
      ssh_key_path     = var.rke_ssh_key_path
    }
  }

  upgrade_strategy {
    drain                  = true
    max_unavailable_worker = "35%"
  }

  services {
    kube_api {
      service_cluster_ip_range = "10.43.0.0/16"
    }
    kube_controller {
      cluster_cidr             = "10.42.0.0/16"
      service_cluster_ip_range = "10.43.0.0/16"
    }
    kubelet {
      cluster_domain     = "cluster.local"
      cluster_dns_server = "10.43.0.10"
      extra_binds = [
        "/var/lib/dockershim:/var/lib/dockershim",
        "/var/lib/cri-dockerd:/var/lib/cri-dockerd"
      ]
    }
  }

  network {
    plugin = "canal"
  }

  authentication {
    strategy = "x509"
  }

  authorization {
    mode = "rbac"
  }
}

resource "time_sleep" "wait_for_rke" {
  depends_on      = [rke_cluster.cluster]
  create_duration = "30s"
}

# --------------------------------------------------
# Kubernetes
# --------------------------------------------------

provider "kubernetes" {
  host                   = rke_cluster.cluster.api_server_url
  username               = rke_cluster.cluster.kube_admin_user
  client_certificate     = rke_cluster.cluster.client_cert
  client_key             = rke_cluster.cluster.client_key
  cluster_ca_certificate = rke_cluster.cluster.ca_crt
}

resource "kubernetes_namespace" "cattle_system" {
  metadata {
    labels = {
      created_by = "Terraform"
    }
    name = var.rancher_namespace
  }
  depends_on = [
    rke_cluster.cluster,
    time_sleep.wait_for_rke
  ]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    labels = {
      created_by = "Terraform"
    }
    name = var.cert_manager_namespace
  }
  depends_on = [
    rke_cluster.cluster,
    time_sleep.wait_for_rke
  ]
}

# --------------------------------------------------
# Helm
# --------------------------------------------------

provider "helm" {
  kubernetes {
    host                   = rke_cluster.cluster.api_server_url
    username               = rke_cluster.cluster.kube_admin_user
    client_certificate     = rke_cluster.cluster.client_cert
    client_key             = rke_cluster.cluster.client_key
    cluster_ca_certificate = rke_cluster.cluster.ca_crt
  }
}

# --------------------------------------------------
# Cert-manager
# --------------------------------------------------

resource "helm_release" "cert_manager" {
  name             = var.cert_manager_name
  chart            = var.cert_manager_chart
  repository       = var.cert_manager_repository
  version          = var.cert_manager_chart_version
  namespace        = var.cert_manager_namespace
  force_update     = var.cert_manager_force_update
  create_namespace = var.cert_manager_create_namespace

  set {
    name  = "installCRDs"
    value = true
  }
  depends_on = [
    rke_cluster.cluster,
    time_sleep.wait_for_rke,
    kubernetes_namespace.cert_manager
  ]
}

resource "time_sleep" "wait_for_cert_manager" {
  depends_on      = [helm_release.cert_manager]
  create_duration = "30s"
}

# --------------------------------------------------
# Rancher
# --------------------------------------------------

provider "rancher2" {
  alias     = "bootstrap"
  api_url   = local.rke_api_url
  bootstrap = true
  insecure  = true
  timeout   = "3s"
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*-_=+:?"
}

resource "helm_release" "rancher" {
  name       = var.rancher_name
  chart      = var.rancher_chart
  repository = var.rancher_repository
  version    = var.rancher_chart_version
  namespace  = var.rancher_namespace
  set {
    name  = "hostname"
    value = var.rancher_ingress_hostname
  }
  set {
    name  = "bootstrapPassword"
    value = "admin"
  }
  depends_on = [
    helm_release.cert_manager,
    kubernetes_namespace.cattle_system,
    time_sleep.wait_for_cert_manager
  ]
}

resource "time_sleep" "wait_for_rancher" {
  depends_on      = [helm_release.rancher]
  create_duration = "60s"
}

resource "rancher2_bootstrap" "bootstrap" {
  provider         = rancher2.bootstrap
  initial_password = "admin"
  password         = random_password.password.result
  depends_on = [
    helm_release.rancher,
    kubernetes_namespace.cattle_system,
    random_password.password,
    time_sleep.wait_for_rancher
  ]
}

provider "rancher2" {
  alias     = "admin"
  api_url   = rancher2_bootstrap.bootstrap.url
  token_key = rancher2_bootstrap.bootstrap.token
  insecure  = true
}

data "rancher2_cluster" "local" {
  provider = rancher2.admin
  name     = "local"
  depends_on = [
    helm_release.rancher,
    rancher2_bootstrap.bootstrap
  ]
}

resource "rancher2_app_v2" "monitoring" {
  provider   = rancher2.admin
  cluster_id = data.rancher2_cluster.local.id
  name       = "rancher-monitoring"
  namespace  = "cattle-monitoring-system"
  repo_name  = "rancher-charts"
  chart_name = "rancher-monitoring"
  depends_on = [
    helm_release.rancher,
    rancher2_bootstrap.bootstrap
  ]
}

resource "rancher2_app_v2" "cis_benchmark" {
  provider   = rancher2.admin
  cluster_id = data.rancher2_cluster.local.id
  name       = "rancher-cis-benchmark"
  namespace  = "cis-operator-system"
  repo_name  = "rancher-charts"
  chart_name = "rancher-cis-benchmark"
  depends_on = [
    helm_release.rancher,
    rancher2_bootstrap.bootstrap
  ]
}
