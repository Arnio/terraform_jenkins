resource "google_compute_firewall" "www" {
  name    = "tf-www-firewall"
  network = "${google_compute_network.default.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["web"]
}
resource "google_compute_instance" "jenkins-master" {
  name         = "jenkins-master"
  machine_type = "g1-small"
  zone         = "us-west1-a"

  tags = ["jenkins", "ansible"]

  boot_disk {
    initialize_params {
      image = "centos-7-v20190213"
    }
  }

#   // Local SSD disk
#   scratch_disk {
#   }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  #  metadata {
  #   sshKeys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  #  }


  metadata_startup_script = <<SCRIPT
  sudo yum -y update
  curl https://d2znqt9b1bc64u.cloudfront.net/java-1.8.0-amazon-corretto-devel-1.8.0_202.b08-2.x86_64.rpm -o java-1.8.0-amazon-corretto-devel-1.8.0_202.b08-2.x86_64.rpm -s
  sudo yum -y localinstall java-1.8.0-amazon-corretto-devel-1.8.0_202.b08-2.x86_64.rpm
  sudo curl http://pkg.jenkins-ci.org/redhat/jenkins.repo -O /etc/yum.repos.d/jenkins.repo -s
  sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
  sudo yum -y upgrade
  sudo yum -y install jenkins
  sudo systemctl start jenkins
  sudo /sbin/chkconfig jenkins on
  # firewall-cmd --permanent --new-service=jenkins
  # firewall-cmd --permanent --service=jenkins --set-short="Jenkins Service Ports"
  # firewall-cmd --permanent --service=jenkins --set-description="Jenkins service firewalld port exceptions"
  # firewall-cmd --permanent --service=jenkins --add-port=8080/tcp
  # firewall-cmd --permanent --add-service=jenkins
  # firewall-cmd --zone=public --add-service=http --permanent
  # firewall-cmd --reload
  curl https://www-us.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz -o apache-maven-3.6.0-bin.tar.gz -s
  sudo tar -xzf apache-maven-3.6.0-bin.tar.gz -C /opt
  echo $JAVA_HOME
  export PATH=/opt/apache-maven-3.6.0/bin:$PATH
  #Install ansible
  sudo yum -y install epel-release
  sudo yum -y install ansible
  SCRIPT

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
resource "google_compute_network" "default" {
  name = "local-test-network"
}