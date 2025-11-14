variable "host_project"{
  description = "The GCP project ID for the host project."
  type        = string
}
variable "service_project"{
  description = "The GCP project ID for the service project."
  type        = string
}
variable "deploy_region" {
  description = "The GCP region to deploy resources in."
  type        = string
}
