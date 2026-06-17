# -------------------------------------------------------------------------
# Delegated Platform DNS
# -------------------------------------------------------------------------
resource "google_dns_managed_zone" "delegated_platform_zone" {
  project     = var.project_id
  name        = var.delegated_dns_managed_zone_name
  dns_name    = "gcp.ajdininfrastructure.lol."
  description = "Delegated platform DNS zone for ExternalDNS records and cert-manager DNS-01 validation."
  visibility  = "public"
}
