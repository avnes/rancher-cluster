# --------------------------------------------------
# GitHub
# --------------------------------------------------

variable "github_owner" {
  type        = string
  default     = null
  description = "GitHub owner"
}

variable "github_token" {
  type        = string
  default     = null
  description = "GitHub token"
}

variable "github_repository_name" {
  type        = string
  default     = null
  description = "GitHub repository name"
}

variable "github_repository_visibility" {
  type        = string
  default     = "private"
  description = "How visible is the GitHub repo?"
  validation {
    condition     = var.github_repository_visibility == "private" || var.github_repository_visibility == "public"
    error_message = "The repository_visibility value must be either private or public."
  }
}

variable "github_vulnerability_alerts" {
  type        = bool
  default     = true
  description = "Should vulnerability alerts be sent to repository owner?"
}

variable "github_repository_branch" {
  type        = string
  default     = "main"
  description = "GitHub repository branch name"
}

# --------------------------------------------------
# Rancher Kubernetes Engine (RKE)
# --------------------------------------------------

variable "rke_cluster_yaml" {
  type        = string
  default     = "cluster.yml"
  description = "The filename for the cluster configuration."
}

variable "rke_kubeconfig" {
  type        = string
  default     = "kube_config_cluster.yml"
  description = "The filename for the cluster kubeconfig."
}

variable "rke_statefile" {
  type        = string
  default     = "cluster.rkestate"
  description = "The filename for the cluster state file."
}

variable "rke_debug" {
  type        = bool
  default     = false
  description = "Debug log level for RKE provisioning"
}

variable "rke_node_username" {
  type        = string
  default     = "rancher"
  description = "The username to connect to the node with."
}

variable "rke_ssh_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa"
  description = "The SSH private key to connect to the node with."
}

variable "rke_cluster_name" {
  type        = string
  default     = null
  description = "RKE cluster name."
}

variable "rke_kubernetes_version" {
  type        = string
  default     = null
  description = "Kubernetes version."
}

variable "rke_enable_cri_dockerd" {
  type        = bool
  default     = false
  description = "Use CRI-O"
}


variable "rke_nodes" {
  type = list(object({
    internal_address = string
    address          = string
    role             = list(string)
  }))
  description = "The list of nodes to install RKE on."
}


# --------------------------------------------------
# Cert-Manager
# --------------------------------------------------

variable "cert_manager_name" {
  type        = string
  default     = "cert-manager"
  description = "Release name."
}

variable "cert_manager_chart" {
  type        = string
  default     = "cert-manager"
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if repository is specified."
}

variable "cert_manager_repository" {
  type        = string
  default     = "https://charts.jetstack.io"
  description = "Repository URL where to locate the requested chart."
}

variable "cert_manager_chart_version" {
  type        = string
  default     = null
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
}

variable "cert_manager_namespace" {
  type        = string
  default     = "cert-manager"
  description = "The namespace to install the release into. Defaults to default namespace."
}

variable "cert_manager_force_update" {
  type        = bool
  default     = false
  description = "Force resource update through delete/recreate if needed. Defaults to false."
}

variable "cert_manager_create_namespace" {
  type        = bool
  default     = false
  description = "Create the namespace if it does not yet exist. Defaults to false."
}

variable "cert_manager_skip_crds" {
  type        = bool
  default     = false
  description = "If set, no CRDs will be installed. By default, CRDs are installed if not already present. Defaults to false."
}

variable "cert_manager_install_crds" {
  type        = bool
  default     = true
  description = "Install cert-manager CRDs. If you don't install them here, you need to install them first."
}

# --------------------------------------------------
# Rancher
# --------------------------------------------------

variable "rancher_name" {
  type        = string
  default     = "rancher"
  description = "Release name."
}

variable "rancher_chart" {
  type        = string
  default     = "rancher"
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if repository is specified."
}

variable "rancher_repository" {
  type        = string
  default     = "https://releases.rancher.com/server-charts/stable"
  description = "Repository URL where to locate the requested chart."
}

variable "rancher_chart_version" {
  type        = string
  default     = null
  description = "Specify the exact chart version to install. If this is not specified, the latest version is installed."
}

variable "rancher_namespace" {
  type        = string
  default     = "cattle-system"
  description = "The namespace to install the release into. Defaults to default cattle-system."
}

variable "rancher_ingress_hostname" {
  type        = string
  default     = null
  description = "The FQDN hostname for the desired ingress."
}
