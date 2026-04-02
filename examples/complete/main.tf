module "valkey" {
  source = "../../"

  service_name       = "your-ovh-project-id"
  valkey_description = "Production Valkey cluster - Team Platform"
  valkey_version     = "8.1"
  valkey_plan        = "business"
  valkey_flavor      = "b3-8"
  valkey_disk_size   = 100

  valkey_deletion_protection = true
  valkey_backup_time         = "03:00"
  valkey_backup_regions      = ["GRA"]

  valkey_advanced_configuration = {
    "maxmemory-policy" = "allkeys-lru"
  }

  valkey_nodes = [
    {
      region     = "GRA"
      network_id = "pn-xxxxxx"
      subnet_id  = "subnet-yyyyyy"
    },
    {
      region     = "GRA"
      network_id = "pn-xxxxxx"
      subnet_id  = "subnet-yyyyyy"
    },
  ]

  valkey_ip_restrictions = [
    { ip = "10.0.0.0/8", description = "Private RFC1918" },
  ]

  valkey_users = [
    {
      name       = "app-rw"
      categories = ["+@all"]
      channels   = ["*"]
      commands   = ["+@all"]
      keys       = ["app:*"]
    },
    {
      name       = "monitoring"
      categories = ["+@all"]
      channels   = ["*"]
      commands   = ["+@read"]
      keys       = ["*"]
    },
  ]
}

output "valkey_id" {
  value = module.valkey.valkey_id
}

output "endpoints" {
  value = module.valkey.valkey_endpoints
}

output "users" {
  value     = module.valkey.valkey_users
  sensitive = true
}
