provider "google" {
  credentials = "${file("f:/SSHkey/gcp_devops.json")}"
  project     = "lyrical-chassis-232614"
  region      = "us-central1"
}