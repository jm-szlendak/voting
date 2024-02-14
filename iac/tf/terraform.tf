terraform {
  required_version = "~> 1.6"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "0.3.10"
    }
  }
}
