# # Enable required APIs for Service Project
# resource "google_project_service" "backupdr_api" {
#   provider = google.service-project
#   project  = var.service_project
#   service  = "backupdr.googleapis.com"

#   disable_on_destroy = false
  
#   timeouts {
#     create = "30m"
#     update = "40m"
#   }
# }

# # Wait for API to propagate
# resource "time_sleep" "wait_for_backupdr_api" {
#   depends_on = [google_project_service.backupdr_api]
  
#   create_duration = "120s"
# }

# resource "google_project_service" "compute_api" {
#   provider = google.service-project
#   project  = var.service_project
#   service  = "compute.googleapis.com"

#   disable_on_destroy = false
# }

# resource "google_project_service" "servicenetworking_api" {
#   provider = google.service-project
#   project  = var.service_project
#   service  = "servicenetworking.googleapis.com"

#   disable_on_destroy = false
# }

# # Enable required APIs for Host Project
# resource "google_project_service" "compute_api_host" {
#   provider = google
#   project  = var.host_project
#   service  = "compute.googleapis.com"

#   disable_on_destroy = false
# }

resource "google_project_service" "backupdr_api_host" {
  provider = google
  project  = var.host_project
  service  = "backupdr.googleapis.com"
  disable_on_destroy = false
}