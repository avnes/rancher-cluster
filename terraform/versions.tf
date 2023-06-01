terraform {
  required_version = ">= 1.2.0"

  required_providers {
    rke = {
      source  = "rancher/rke"
      version = "~> 1.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10.0"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}
