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

variable "deploy_zone" {
  description = "The GCP zone to deploy the VM in."
  type        = string
}

variable "machine_type" {
  description = "The machine type for the VM instance."
  type        = string
  default     = "e2-medium"
}

variable "network_name" {
  description = "The name of the VPC network."
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet."
  type        = string
}

