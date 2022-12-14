terraform {
  required_version = ">= 1.2.0"

  required_providers {
    rke = {
      source  = "rancher/rke"
      version = "~> 1.3.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 1.25.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}
