provider "google" {
  credentials = "${file("f:/SSHkey/gcp_devops.json")}"
  project     = "${var.my_gcp_project}"
  region      = "${var.region}"
}