# Compute Engine Instance with Nginx
resource "google_compute_instance" "nginx_vm_1" {
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

# Compute Engine Instance with MySQL on Host Project
resource "google_compute_instance" "mysql_vm" {
  provider     = google  # Uses the default provider (host project)
  name         = "mysql-vm-1"
  machine_type = var.machine_type
  zone         = var.deploy_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
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
    
    # Set MySQL root password (change this for production!)
    MYSQL_ROOT_PASSWORD="ChangeMe123!"
    
    # Pre-configure MySQL installation
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD"
    
    # Install MySQL Server
    apt-get install -y default-mysql-server
    
    # Secure MySQL installation
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<MYSQL_SCRIPT
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;
    MYSQL_SCRIPT
    
    # Configure MySQL to listen on all interfaces (optional - for remote access)
    sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
    
    # Restart MySQL
    systemctl restart mysql
    systemctl enable mysql
    
    # Create a test database
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<MYSQL_SCRIPT
    CREATE DATABASE IF NOT EXISTS testdb;
    CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'AppPassword123!';
    GRANT ALL PRIVILEGES ON testdb.* TO 'appuser'@'%';
    FLUSH PRIVILEGES;
    MYSQL_SCRIPT
    
    # Save MySQL credentials to a file for reference
    cat > /root/mysql_credentials.txt <<CREDS
    MySQL Root Password: $MYSQL_ROOT_PASSWORD
    Application User: appuser
    Application Password: AppPassword123!
    Test Database: testdb
    CREDS
    
    chmod 600 /root/mysql_credentials.txt
  EOF

  tags = ["mysql-server"]

  labels = {
    environment = "production"
    application = "mysql"
  }
}

# Firewall rule to allow MySQL traffic (3306)
resource "google_compute_firewall" "allow_mysql" {
  provider    = google  # Host project
  name        = "allow-mysql-db"
  network     = var.network_name
  description = "Allow MySQL traffic to database VM"

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }

  # Restrict to internal network for security
  # Change source_ranges to your specific IPs or VPC CIDR
  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["mysql-server"]
}

# Firewall rule to allow SSH access to MySQL VM
resource "google_compute_firewall" "allow_ssh_mysql" {
  provider    = google  # Host project
  name        = "allow-ssh-mysql"
  network     = var.network_name
  description = "Allow SSH access to MySQL VM"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mysql-server"]
}

