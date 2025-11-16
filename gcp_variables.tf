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
variable "mc_name" {
  description = "The name of the Backup DR Management Server."
  type        = string
}
variable "mc_type" {
  description = "The type of the Backup DR Management Server."
  type        = string
}
variable "backup_dr_subnet_range"{
    description = "The ip range of the Backup DR subnet."
    type        = string
}
variable "backup_dr_appliance_name"{
    description = "The name of the Backup DR subnet."
    type        = string
}
variable "backup_dr_fw_source_ranges"{
    description = "The source ranges for Backup DR firewall rules."
    type        = list(string)
}
