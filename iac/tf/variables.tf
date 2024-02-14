variable "environment" {
  type        = string
  description = "name of the environment to deploy"
}

variable "kubeconfig_path" {
  type        = string
  description = "path to kubeconfig file"
  default     = "~/.kube/config"
}

variable "deployTag" {
  type          = string
  description = "docker image tag to be deployed"
}
