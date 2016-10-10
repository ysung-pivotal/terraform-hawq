output "ambari_public_hostname" {
  value = "${google_compute_instance.ambari.network_interface.0.access_config.0.assigned_nat_ip}"
}