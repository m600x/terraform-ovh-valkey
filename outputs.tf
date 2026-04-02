############################################
# Database identifiers
############################################

output "valkey_id" {
  description = "Valkey database ID"
  value       = ovh_cloud_project_database.this.id
}

output "valkey_engine" {
  description = "Database engine"
  value       = ovh_cloud_project_database.this.engine
}

output "valkey_version" {
  description = "Valkey version"
  value       = ovh_cloud_project_database.this.version
}

############################################
# Network / endpoints
############################################

output "valkey_endpoints" {
  description = "Valkey endpoints"
  value       = ovh_cloud_project_database.this.endpoints
}

############################################
# Nodes
############################################

output "valkey_nodes" {
  description = "Valkey nodes configuration"
  value       = ovh_cloud_project_database.this.nodes
}

############################################
# Status / lifecycle
############################################

output "valkey_status" {
  description = "Current Valkey database status"
  value       = ovh_cloud_project_database.this.status
}

############################################
# Users
############################################

output "valkey_users" {
  description = "Created Valkey users"
  value       = ovh_cloud_project_database_valkey_user.user
  sensitive   = true
}
