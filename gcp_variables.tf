variable "gcp_credentials_path" {
  description = "File path to the downloaded Google Cloud Platform credentials"
}

variable "gcp_project" {
  description = "The ID of the GCP project to create compute instances"
}

variable "gcp_region" {
  description = "The GCP region to operate under"
  default = "us-east1"
}

variable "gcp_zone" {
  description = "The GCP zone to operate under"
  default = "us-east1-d"
}

variable "gcp_clustername" {
  description = "Name of the cluster"
  default = "hawq"
}

variable "gcp_cluster_network" {
    default = "10.0.0.0/24"
}

variable "gcp_image" {
  description = "The image from which to initialize GCP compute instances"
  default = "centos-6"
}

variable "gcp_publickey_path" {
  description = "Path to file containing public key"
  default = "~/.ssh/gcloud_id_rsa.pub"
}

variable "gcp_privatekey_path" {
  description = "Path to file containing private key"
  default = "~/.ssh/gcloud_id_rsa"
}

variable "ambari_machine_type" {
  description = "GCP compute instance type of Ambari node"
  default = "n1-standard-4"
}

variable "cluster_machine_type" {
  description = "GCP compute instance type of cluster nodes"
  default = "n1-standard-8"
}

variable "cluster_size" {
  description = "Number of cluster nodes"
  default = "6"
}

variable "pivotal_token" {
  description = "Pivotal Network token"
}

variable "hawq_password" {
  description = "Password for HAWQ user (gpadmin)"
}

variable "hdp_version" {
  description = "Version of Hortonworks Data Platform (HDP) to be installed"
  default = "2.4"
}

variable "hdp_services" {
  description = "Hortonworks Data Platform (HDP) services to be installed"
  default = "HDFS MAPREDUCE2 YARN ZOOKEEPER PIG HIVE TEZ AMBARI_METRICS HAWQ PXF HBASE SPARK"
}

variable "dpod_dir" {
  description = "Directory to hold auto provisioning scripts"
}