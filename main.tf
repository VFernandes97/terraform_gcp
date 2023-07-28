provider "google" {
  version = "3.5.0"
  credentials = file("credential-path")
  project = "project-name"
  region  = "region"
  zone    = "zone"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet-1" {
  name          = "tf-master-subnet-1"
  ip_cidr_range = "172.89.0.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "subnet-2" {
  name          = "tf-worker-subnet-2"
  ip_cidr_range = "172.89.1.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }
  allow {
  protocol = "udp"
    ports    = ["1-65535"]
  }
   allow {
  protocol = "icmp"
  }
  source_ranges = ["172.89.0.0/24", "172.89.1.0/24",]
}

resource "google_compute_firewall" "connect-from-browser" {
  name    = "connect-from-browser"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20",]
}

resource "google_compute_instance" "vm_master" {
  count = 1
  name         = "master-${count.index + 1}"
  machine_type = "e2-medium"
  zone         = "us-west1-a"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet-1.name
    access_config {
    }
  }
}

resource "google_compute_instance" "vm_worker" {
  count = 2
  name         = "worker-${count.index + 1}"
  machine_type = "e2-medium"
  zone         = "us-west1-a"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet-2.name
    access_config {
    }
  }
}