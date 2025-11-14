# Compute Engine Instance with Nginx
resource "google_compute_instance" "nginx_vm_1" {
  provider     = google.service-project
  name         = "nginx-vm-1"
  machine_type = var.machine_type
  zone         = var.deploy_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name

    access_config {
      # Ephemeral public IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Update package list
    apt-get update
    
    # Install Nginx
    apt-get install -y nginx
    
    # Create custom landing page
    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
        <title>Welcome to VM 1</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 50px;
                background-color: #f0f0f0;
            }
            .container {
                background-color: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            h1 {
                color: #4285f4;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>HOLA SOY VM NUMBER 1</h1>
            <p>Welcome to Nginx on Debian</p>
            <p>Server is running successfully!</p>
        </div>
    </body>
    </html>
    HTML
    
    # Restart Nginx to ensure it's running
    systemctl restart nginx
    systemctl enable nginx
  EOF

  tags = ["http-server", "https-server"]

  labels = {
    environment = "production"
    application = "nginx"
  }
}

# Firewall rule to allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  provider    = google.service-project
  name        = "allow-http-nginx"
  network     = var.network_name
  description = "Allow HTTP traffic to Nginx VM"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# Firewall rule to allow HTTPS traffic (optional)
resource "google_compute_firewall" "allow_https" {
  provider    = google.service-project
  name        = "allow-https-nginx"
  network     = var.network_name
  description = "Allow HTTPS traffic to Nginx VM"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}
