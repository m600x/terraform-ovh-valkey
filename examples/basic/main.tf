module "valkey" {
  source = "../../"

  service_name   = "your-ovh-project-id"
  valkey_version = "8.1"
  valkey_plan    = "essential"
  valkey_flavor  = "b3-8"

  valkey_nodes = [
    { region = "GRA" },
    { region = "GRA" },
  ]

  create_valkey_users = false
}

output "valkey_id" {
  value = module.valkey.valkey_id
}

output "endpoints" {
  value = module.valkey.valkey_endpoints
}
