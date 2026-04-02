############################################
# Global
############################################

variable "service_name" {
  description = "OVH project service name (project ID)"
  type        = string
}

############################################
# Valkey configuration
############################################

variable "valkey_description" {
  description = "Description of the Valkey database"
  type        = string
  default     = null
}

variable "valkey_version" {
  description = "Valkey engine version (e.g. 7.2, 8.1)"
  type        = string

  validation {
    condition     = can(regex("^\\d+\\.\\d+$", var.valkey_version))
    error_message = "valkey_version must follow the format 'X.Y' (e.g. 7.2, 8.1)."
  }
}

variable "valkey_plan" {
  description = "Valkey plan (essential, business, enterprise)"
  type        = string

  validation {
    condition     = contains(["essential", "business", "enterprise"], var.valkey_plan)
    error_message = "valkey_plan must be one of: essential, business, enterprise."
  }
}

variable "valkey_flavor" {
  description = "Valkey flavor (e.g. b3-8)"
  type        = string
}

variable "valkey_disk_size" {
  description = "Disk size in GB (optional, OVH default if null)"
  type        = number
  default     = null

  validation {
    condition = (
      var.valkey_disk_size == null ||
      (var.valkey_disk_size == floor(var.valkey_disk_size) && var.valkey_disk_size > 0)
    )
    error_message = "valkey_disk_size must be a positive integer when set."
  }
}

variable "valkey_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

############################################
# Backup & maintenance
############################################

variable "valkey_backup_time" {
  description = "Backup time in HH:MM format (UTC)"
  type        = string
  default     = null

  validation {
    condition     = var.valkey_backup_time == null || can(regex("^([01]\\d|2[0-3]):[0-5]\\d$", var.valkey_backup_time))
    error_message = "valkey_backup_time must follow HH:MM format (e.g. 03:00)."
  }
}

variable "valkey_backup_regions" {
  description = "List of regions where backups are stored"
  type        = list(string)
  default     = null
}

############################################
# Advanced configuration
############################################

variable "valkey_advanced_configuration" {
  description = "Advanced Valkey configuration (Redis-compatible key/value pairs)"
  type        = map(string)
  default     = null
}

############################################
# Nodes
############################################

variable "valkey_nodes" {
  description = "List of Valkey nodes (minimum 2 for HA)"
  type = list(object({
    region     = string
    network_id = optional(string)
    subnet_id  = optional(string)
  }))

  validation {
    condition     = length(var.valkey_nodes) >= 2
    error_message = "At least two Valkey nodes must be defined for high availability."
  }
}

############################################
# IP restrictions
############################################

variable "valkey_ip_restrictions" {
  description = "List of IP restrictions for Valkey access"
  type = list(object({
    ip          = string
    description = optional(string)
  }))
  default = null
}

############################################
# Valkey Users
############################################

variable "create_valkey_users" {
  description = "Enable or disable Valkey user creation"
  type        = bool
  default     = true
}

variable "valkey_users" {
  description = "List of Valkey users with ACL configuration"
  type = list(object({
    name       = string
    categories = list(string)
    channels   = list(string)
    commands   = list(string)
    keys       = list(string)
  }))
  default = []

  validation {
    condition     = length(var.valkey_users) == length(distinct([for u in var.valkey_users : u.name]))
    error_message = "User names must be unique."
  }
}
