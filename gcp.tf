provider "google" {
  region = "${var.gcp_region}"
  project = "${var.gcp_project}"
  credentials = "${file("${var.gcp_credentials_path}")}"
}

# Templates
data "template_file" "userdata" {
  template = "${file("${path.module}/templates/userdata.sh.tpl")}"
  vars {
    dpod_dir = "${var.dpod_dir}"
  }
}

data "template_file" "zeppelin" {
  template = "${file("${path.module}/templates/zeppelin.sh.tpl")}"
  vars {
    stack_version = "${var.hdp_version}"
  }
}

data "template_file" "hdb" {
  template = "${file("${path.module}/templates/hdb.sh.tpl")}"
  vars {
    pivotal_token = "${var.pivotal_token}"
    dpod_dir = "${var.dpod_dir}"
  }
}

data "template_file" "configuration_custom" {
  template = "${file("${path.module}/templates/configuration-custom.1.json.tpl")}"
  vars {
    hawq_password = "${var.hawq_password}"
  }
}

data "template_file" "deploy" {
  template = "${file("${path.module}/templates/deploy.sh.tpl")}"
  vars {
    cluster_size = "${var.cluster_size}"
    hdp_services = "${var.hdp_services}"
    stack_version = "${var.hdp_version}"
    dpod_dir = "${var.dpod_dir}"
  }
}

data "template_file" "segment_catalog" {
  template = "${file("${path.module}/templates/hawq_segment.sh.tpl")}"
  vars {
    dpod_dir = "${var.dpod_dir}"
  }
}

# GCP resources for the cluster
resource "google_compute_network" "cluster-global-net" {
    name = "${var.gcp_clustername}-global-net"
    auto_create_subnetworks = false # custom subnetted network will be created that can support google_compute_subnetwork resources
}

resource "google_compute_subnetwork" "cluster-net" {
    name = "${var.gcp_clustername}-${var.gcp_region}-net"
    ip_cidr_range = "${var.gcp_cluster_network}"
    network = "${google_compute_network.cluster-global-net.self_link}" # parent network
}

resource "google_compute_instance" "ambari" {
  name = "${var.gcp_clustername}-ambari"
  machine_type = "${var.ambari_machine_type}"
  zone = "${var.gcp_zone}"
  tags = ["ambari", "ssh"]

  disk {
    image = "${var.gcp_image}"
    size = "100"
  }
  
  network_interface {
    subnetwork = "${google_compute_subnetwork.cluster-net.name}"
    access_config {
      # Ephemeral IP
    }
  }

  metadata {
    ssh-keys = "root:${file("${var.gcp_publickey_path}")}"
  }

  metadata_startup_script = "${file("${path.module}/scripts/metadata_script.sh")}"

  connection {
    type = "ssh"
    user = "root"
    private_key = "${file("${var.gcp_privatekey_path}")}"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.dpod_dir}"
    ]
  }

  provisioner "file" {
    content = "${data.template_file.userdata.rendered}"
    destination = "${var.dpod_dir}/userdata.sh"
  }

  provisioner "file" {
    source = "${path.module}/scripts/setup.sh"
    destination = "${var.dpod_dir}/setup.sh"
  }

  provisioner "file" {
    source = "${path.module}/scripts/config-custom.sh"
    destination = "${var.dpod_dir}/config-custom.sh"
  }

  provisioner "file" {
    content = "${data.template_file.zeppelin.rendered}"
    destination = "${var.dpod_dir}/zeppelin.sh"
  }

  provisioner "file" {
    content = "${data.template_file.hdb.rendered}"
    destination = "${var.dpod_dir}/hdb.sh"
  }

  provisioner "file" {
    content = "${data.template_file.configuration_custom.rendered}"
    destination = "${var.dpod_dir}/configuration-custom.json"
  }

  provisioner "file" {
    content = "${data.template_file.deploy.rendered}"
    destination = "${var.dpod_dir}/deploy.sh"
  }

  provisioner "file" {
    content = "${data.template_file.segment_catalog.rendered}"
    destination = "${var.dpod_dir}/hawq_segment.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ${var.dpod_dir}/*.sh",
      "bash ${var.dpod_dir}/userdata.sh",
      "bash ${var.dpod_dir}/setup.sh > ${var.dpod_dir}/setup.log",
      "git clone https://github.com/seanorama/ambari-bootstrap.git ${var.dpod_dir}/ambari-bootstrap",
      "chmod +x ${var.dpod_dir}/ambari-bootstrap/ambari-bootstrap.sh",
      "export install_ambari_agent=false",
      "export install_ambari_server=true",
      "export java_provider=oracle",
      "export ambari_version=2.2.2.0",
      "bash ${var.dpod_dir}/ambari-bootstrap/ambari-bootstrap.sh",
      "bash ${var.dpod_dir}/zeppelin.sh",
      "bash ${var.dpod_dir}/hdb.sh"
    ]
  }
}

resource "google_compute_instance" "cluster_node" {
  count = "${var.cluster_size}"
  
  name = "${var.gcp_clustername}-node-${count.index}"
  machine_type = "${var.cluster_machine_type}"
  zone = "${var.gcp_zone}"
  tags = ["ssh", "hdp"]

  disk {
    image = "${var.gcp_image}"
    type = "pd-ssd"
    size = "500"
  }
  
  network_interface {
    subnetwork = "${google_compute_subnetwork.cluster-net.name}"
    access_config {
      # Ephemeral IP
    }
  }

  metadata {
    ssh-keys = "root:${file("${var.gcp_publickey_path}")}"
  }

  metadata_startup_script = "${file("${path.module}/scripts/metadata_script.sh")}"

  connection {
    type = "ssh"
    user = "root"
    private_key = "${file("${var.gcp_privatekey_path}")}"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${var.dpod_dir}"
    ]
  }

  provisioner "file" {
    content = "${data.template_file.userdata.rendered}"
    destination = "${var.dpod_dir}/userdata.sh"
  }

  provisioner "file" {
    source = "${path.module}/scripts/setup.sh"
    destination = "${var.dpod_dir}/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -o ${var.dpod_dir}/ambari-bootstrap.sh -sSL https://raw.githubusercontent.com/seanorama/ambari-bootstrap/master/ambari-bootstrap.sh",
      "chmod +x ${var.dpod_dir}/*.sh",
      "bash ${var.dpod_dir}/userdata.sh",
      "bash ${var.dpod_dir}/setup.sh > ${var.dpod_dir}/setup.log",
      "export install_ambari_agent=true",
      "export install_ambari_server=false",
      "export java_provider=oracle",
      "export ambari_server=${google_compute_instance.ambari.network_interface.0.address}",
      "export ambari_version=2.2.2.0",
      "bash ${var.dpod_dir}/ambari-bootstrap.sh"
    ]
  }
}