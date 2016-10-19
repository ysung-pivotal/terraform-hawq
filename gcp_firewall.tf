resource "google_compute_firewall" "cluster-internal" {
    name = "${var.gcp_clustername}-internal"
    network = "${google_compute_network.cluster-global-net.name}"

    allow {
        protocol = "tcp"
        ports = ["1-65535"]
    }
    allow {
        protocol = "udp"
        ports = ["1-65535"]
    }
    allow {
        protocol = "icmp"
    }

    source_ranges = ["${google_compute_subnetwork.cluster-net.ip_cidr_range}"]

}

resource "google_compute_firewall" "ambari" {
    name = "${var.gcp_clustername}-${var.gcp_region}-ambari"
    network = "${google_compute_network.cluster-global-net.name}"

    allow {
        protocol = "tcp"
        ports = ["80", "8080"]
    }

    target_tags = ["ambari"]
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ssh" {
    name = "${var.gcp_clustername}-${var.gcp_region}-ssh"
    network = "${google_compute_network.cluster-global-net.name}"

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    target_tags = ["ssh"]
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hdp" {
    name = "${var.gcp_clustername}-${var.gcp_region}-hdp"
    network = "${google_compute_network.cluster-global-net.name}"

    allow {
        protocol = "tcp"
        ports = ["5432", "9995-9996"]
    }

    target_tags = ["hdp"]
    source_ranges = ["0.0.0.0/0"]
}