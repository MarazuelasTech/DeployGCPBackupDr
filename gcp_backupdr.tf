

# Backup and DR Management Server on Service Project
resource "google_backup_dr_management_server" "management_console" {
  provider = google.service-project
  location = var.deploy_region
  name     = "backup-dr-console"
  
  type = "BACKUP_RESTORE"

  networks {
    network    = "projects/${var.service_project}/global/networks/${var.network_name}"
    peering_mode = "PRIVATE_SERVICE_ACCESS"
  }

  depends_on = [google_project_service.backupdr_api]
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

  depends_on = [google_project_service.backupdr_api]
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
  provider                      = google.service-project
  location                      = var.deploy_zone
  backup_plan_association_id    = "nginx-vm-backup-assoc"
  backup_plan                   = google_backup_dr_backup_plan.backup_plan.id
  resource                      = google_compute_instance.nginx_vm_1.id
  resource_type                 = "compute.googleapis.com/Instance"
  
  depends_on = [google_compute_instance.nginx_vm_1]
}

