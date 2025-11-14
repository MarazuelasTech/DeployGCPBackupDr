# Output values for the deployed resources
output "vm_name" {
  description = "Name of the VM instance"
  value       = google_compute_instance.nginx_vm_1.name
}

output "vm_internal_ip" {
  description = "Internal IP address of the VM"
  value       = google_compute_instance.nginx_vm_1.network_interface[0].network_ip
}

output "vm_external_ip" {
  description = "External IP address of the VM"
  value       = google_compute_instance.nginx_vm_1.network_interface[0].access_config[0].nat_ip
}

output "vm_zone" {
  description = "Zone where the VM is deployed"
  value       = google_compute_instance.nginx_vm_1.zone
}

output "nginx_url" {
  description = "URL to access the Nginx landing page"
  value       = "http://${google_compute_instance.nginx_vm_1.network_interface[0].access_config[0].nat_ip}"
}

# MySQL VM Outputs
output "mysql_vm_name" {
  description = "Name of the MySQL VM instance"
  value       = google_compute_instance.mysql_vm.name
}

output "mysql_internal_ip" {
  description = "Internal IP address of the MySQL VM"
  value       = google_compute_instance.mysql_vm.network_interface[0].network_ip
}

output "mysql_external_ip" {
  description = "External IP address of the MySQL VM"
  value       = google_compute_instance.mysql_vm.network_interface[0].access_config[0].nat_ip
}

output "mysql_zone" {
  description = "Zone where the MySQL VM is deployed"
  value       = google_compute_instance.mysql_vm.zone
}

output "mysql_connection_info" {
  description = "MySQL connection information"
  value = <<-EOT
    MySQL Server: ${google_compute_instance.mysql_vm.network_interface[0].network_ip}:3306
    Default Root Password: ChangeMe123! (Change this in production!)
    Application User: appuser
    Application Password: AppPassword123!
    Test Database: testdb
    
    Connect via SSH: gcloud compute ssh mysql-vm-1 --zone=${google_compute_instance.mysql_vm.zone}
    Credentials file on VM: /root/mysql_credentials.txt
  EOT
}
