resource "google_compute_firewall" "jenkins" {
  name    = "${var.firewall_name}"
  network = "${google_compute_subnetwork.default.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "8080", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["jenkins"]
}

resource "google_compute_subnetwork" "default" {
  name                     = "${var.network_name}"
  ip_cidr_range            = "${var.network_cidr}"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = true
}
resource "google_compute_instance" "jenkins-master" {
  name         = "${var.instance_name}"
  machine_type = "${var.instance_type}"
  zone         = "${var.zone}"

  tags = ["jenkins", "ansible"]

  boot_disk {
    initialize_params {
      image = "${var.image_type}"
    }
  }

#   // Local SSD disk
#   scratch_disk {
#   }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.default.name}"
    access_config {
      // Ephemeral IP
    }
  }

    metadata {
     sshKeys = "centos:${file("f:/SSHkey/devops095.pub")}"
    }


  metadata_startup_script = <<SCRIPT
sudo yum -y update
   #Install ansible
sudo yum -y install epel-release
sudo yum -y install ansible
curl https://d2znqt9b1bc64u.cloudfront.net/java-1.8.0-amazon-corretto-devel-1.8.0_202.b08-2.x86_64.rpm -o /tmp/java-1.8.0-amazon-corretto-devel-1.8.0_202.b08-2.x86_64.rpm -s
sudo yum -y localinstall /tmp/java-1.8.0-amazon-corretto-devel-1.8.0_202.b08-2.x86_64.rpm
sudo curl http://pkg.jenkins-ci.org/redhat/jenkins.repo --output /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
sudo yum -y install fontconfig
sudo yum -y upgrade && sudo yum -y install jenkins
sudo systemctl start jenkins
sudo /sbin/chkconfig jenkins on
curl https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz -o /tmp/apache-maven-3.6.0-bin.tar.gz -s
sudo tar -xzf /tmp/apache-maven-3.6.0-bin.tar.gz -C /opt
#sudo sed -i 's/<useSecurity>true/<useSecurity>false/' /var/lib/jenkins/config.xml
sudo systemctl restart jenkins
cat <<EOF | sudo tee -a /etc/profile.d/maven.sh
export M2_HOME=/opt/apache-maven-3.6.0
export MAVEN_HOME=/opt/apache-maven-3.6.0
export PATH=\$M2_HOME/bin:\$PATH
EOF
sudo chmod +x /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

SCRIPT

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
  resource "google_compute_network" "default" {
    name = "${var.network_name}"
    auto_create_subnetworks = false
  }

