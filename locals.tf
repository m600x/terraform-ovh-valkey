locals {
  # Normalize users into a map keyed by name for for_each
  valkey_users = var.create_valkey_users ? {
    for user in var.valkey_users : user.name => user
  } : {}

  # Normalize nullable lists to empty lists for dynamic blocks
  ip_restrictions = coalesce(var.valkey_ip_restrictions, [])
}
