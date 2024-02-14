provider "helm" {
    kubernetes {
      config_path = var.kubeconfig_path
    }
}

resource "helm_release" "voting" {
  name = "voting-${var.environment}"
  chart = "../voting"
  
  set {
    name = "global.environment"
    value = var.environment
  }

  set {
    name = "global.image.tag"
    value = var.tag
  } 
}