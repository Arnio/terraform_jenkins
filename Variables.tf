// PROJECT Variables
variable "my_gcp_project" {
  default = "lyrical-chassis-232614"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}
variable "instance_type" {
  default = "g1-small"
}

variable "image_type" {
  default = "centos-cloud/centos-7"
}
variable "instance_name" {
  default = "jenkins-master"
}

// Network Variables
variable "network_cidr" {
  default = "10.127.0.0/20"
}

variable "network_name" {
  default = "my-network"
}

// FIREWALL Variables
variable "firewall_name" {
  default = "tf-jenkins-firewall"
}

variable "public_key" {
  default = "Your_Public_Key_in_RSA_Format"
}