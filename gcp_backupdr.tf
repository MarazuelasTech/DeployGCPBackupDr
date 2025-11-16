





data "google_compute_network" "network" {
  provider = google
  name     = var.network_name
  project  = var.host_project
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "global-psconnect-ip-${var.network_name}"
  address_type  = "INTERNAL"
  purpose       = "VPC_PEERING"
  prefix_length = 20
  project       = var.host_project
  network       = data.google_compute_network.network.id
}

resource "google_service_networking_connection" "default" {
  network                 = data.google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  
  update_on_creation_fail = true
  
  deletion_policy = "ABANDON"
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "bckp-dr-subnet-${var.network_name}"
  ip_cidr_range            = var.backup_dr_subnet_range
  region                   = var.deploy_region
  project                  = var.host_project
  network                  = data.google_compute_network.network.id
  private_ip_google_access = true
}

resource "google_backup_dr_management_server" "server" {
  provider = google-beta
  location = var.deploy_region
  project  = var.service_project
  name = var.mc_name
  type = var.mc_type
  depends_on = [google_service_networking_connection.default]
}

module "backup_dr_appliance" {
  source  = "GoogleCloudPlatform/backup-dr/google//"
  version = "0.4.0"
  ba_project_id = var.service_project
  region        = var.deploy_region
  zone          = var.deploy_zone
  vpc_host_project_id = var.host_project
  network             = var.network_name
  subnet              = var.subnet_name
  ms_project_id              = var.service_project
  management_server_endpoint = google_backup_dr_management_server.server.management_uri[0].api
  ba_name                    = var.backup_dr_appliance_name
  ba_appliance_type          = "STANDARD_FOR_COMPUTE_ENGINE_VMS"
  create_ba_service_account  = true
  assign_roles_to_ba_sa      = true
  ba_registration            = true
  firewall_source_ip_ranges  = var.backup_dr_fw_source_ranges
  network_tags               = []
  labels                     = {
    managed-by = "terraform"
  }
  depends_on                 = [google_backup_dr_management_server.server, google_service_networking_connection.default]
 }

resource "google_project_iam_member" "host_projects_ervice_account_roles" {
  project    = var.host_project
  role       = "roles/backupdr.computeEngineOperator"
  member     = "serviceAccount:${module.backup_dr_appliance.ba_service_account}"
  depends_on = [module.backup_dr_appliance]
}




resource "google_project_iam_member" "host_project_managementserver_accessor" {
  project    = var.host_project
  role       = "roles/backupdr.managementServerAccessor"
  member     = "serviceAccount:${module.backup_dr_appliance.ba_service_account}"
  depends_on = [module.backup_dr_appliance]
}

# Grant Backup DR service agent permission to access VMs in host project
resource "google_project_iam_member" "backupdr_service_agent" {
  project    = var.host_project
  role       = "roles/backupdr.computeEngineOperator"
  member     = "serviceAccount:vault-${data.google_project.service_project.number}-53762022@gcp-sa-backupdr-pr.iam.gserviceaccount.com"
}

# Get service project number for the service agent
data "google_project" "service_project" {
  project_id = var.service_project
}



# Backup Vault on Service Project
resource "google_backup_dr_backup_vault" "vault" {
  provider                                    = google.service-project
  backup_vault_id                             = "backup-vault"
  location                                    = var.deploy_region
  backup_minimum_enforced_retention_duration  = "86400s"  # 1 day minimum retention

  labels = {
    environment = "production"
  }
}

# Backup Plan for daily backups
resource "google_backup_dr_backup_plan" "backup_plan" {
  provider        = google.service-project
  backup_plan_id  = "daily-backup-plan"
  location        = var.deploy_region
  resource_type   = "compute.googleapis.com/Instance"
  backup_vault    = google_backup_dr_backup_vault.vault.name

  backup_rules {
    rule_id               = "daily-rule"
    backup_retention_days = 30
    
    standard_schedule {
      recurrence_type       = "DAILY"
      hourly_frequency      = 24
      time_zone             = "UTC"
      backup_window {
        start_hour_of_day = 3
        end_hour_of_day   = 5
      }
    }
  }
}

# Protected Resource - Nginx VM
resource "google_backup_dr_backup_plan_association" "nginx_vm_protection" {
  #provider                      = google.service-project
  location                      = var.deploy_region  # Changed from zone to region
  backup_plan_association_id    = "nginx-vm-backup-assoc"
  backup_plan                   = google_backup_dr_backup_plan.backup_plan.id
  resource                      = google_compute_instance.nginx_vm_1.id
  resource_type                 = "compute.googleapis.com/Instance"
  
  depends_on = [google_compute_instance.nginx_vm_1]
}

