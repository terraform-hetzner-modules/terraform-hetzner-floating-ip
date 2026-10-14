variable "ips" {
  description = "Floating IPs keyed by stable identifiers. Names default to map keys. Set home_location for independent IPs, or server_id for inline assignment."
  type = map(object({
    name              = optional(string)
    type              = string
    home_location     = optional(string)
    server_id         = optional(number)
    description       = optional(string)
    delete_protection = optional(bool, true)
    labels            = optional(map(string), {})
  }))
  default  = {}
  nullable = false

  validation {
    condition     = alltrue([for ip in values(var.ips) : contains(["ipv4", "ipv6"], ip.type)])
    error_message = "Each Floating IP type must be ipv4 or ipv6."
  }

  validation {
    condition     = alltrue([for ip in values(var.ips) : ip.home_location != null || ip.server_id != null])
    error_message = "Each Floating IP requires home_location or an inline server_id. Separate assignments require home_location."
  }
}

variable "assignments" {
  description = "Separate assignments keyed by entries in ips. Each value supplies server_id; omit that IP's inline server_id to avoid competing ownership. Keys must be known during planning, but server IDs may be computed."
  type        = map(object({ server_id = number }))
  default     = {}
  nullable    = false
}

variable "labels" {
  description = "Labels shared by all IPs. Per-IP labels take precedence."
  type        = map(string)
  default     = {}
  nullable    = false
}
