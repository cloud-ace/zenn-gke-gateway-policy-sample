# Write to this file when you set the output.
output "endpoint_fqdn" {
  value = google_endpoints_service.gateway.dns_address
}
