variable "environment" {
  type        = string
  description = "name of the environment to deploy"
}

variable "kubeconfig_path" {
  type        = string
  description = "path to kubeconfig file"
  default     = "~/.kube/config"
}

variable "tag" {
  type          = string
  description = "docker image tag to be deployed"
}


variable "image_registry_url" {
  type = string
  description = "docker image registry to which images are uploaded"
  default = "szlendakjakub"
}