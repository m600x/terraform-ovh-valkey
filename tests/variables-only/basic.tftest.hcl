variables {
  service_name   = "test-project-id"
  valkey_version = "8.1"
  valkey_plan    = "essential"
  valkey_flavor  = "b3-8"
  valkey_nodes = [
    { region = "GRA" },
    { region = "GRA" },
  ]
  create_valkey_users = false
}

##############################
# Valid inputs (variable validation only; no OVH resources)
##############################

run "valid_default_variables" {
  command = plan

  assert {
    condition     = length(var.valkey_nodes) >= 2
    error_message = "Default valkey_nodes must satisfy module validation (>= 2 nodes)."
  }
}

##############################
# Validation: reject single node
##############################

run "reject_single_node" {
  command = plan

  variables {
    valkey_nodes = [{ region = "GRA" }]
  }

  expect_failures = [
    var.valkey_nodes,
  ]
}

##############################
# Validation: reject bad version format
##############################

run "reject_bad_version_format" {
  command = plan

  variables {
    valkey_version = "latest"
  }

  expect_failures = [
    var.valkey_version,
  ]
}

##############################
# Validation: reject invalid plan name
##############################

run "reject_invalid_plan" {
  command = plan

  variables {
    valkey_plan = "free-tier"
  }

  expect_failures = [
    var.valkey_plan,
  ]
}

##############################
# Validation: reject bad backup time
##############################

run "reject_bad_backup_time" {
  command = plan

  variables {
    valkey_backup_time = "25:00"
  }

  expect_failures = [
    var.valkey_backup_time,
  ]
}

##############################
# Validation: reject duplicate user names
##############################

run "reject_duplicate_users" {
  command = plan

  variables {
    create_valkey_users = true
    valkey_users = [
      {
        name       = "app"
        categories = ["+@all"]
        channels   = ["*"]
        commands   = ["+@all"]
        keys       = ["*"]
      },
      {
        name       = "app"
        categories = ["+@all"]
        channels   = ["*"]
        commands   = ["+@read"]
        keys       = ["*"]
      },
    ]
  }

  expect_failures = [
    var.valkey_users,
  ]
}

##############################
# Validation: reject negative disk size
##############################

run "reject_negative_disk_size" {
  command = plan

  variables {
    valkey_disk_size = -10
  }

  expect_failures = [
    var.valkey_disk_size,
  ]
}
