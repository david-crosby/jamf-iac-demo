# Computer Groups Module
# This module creates computer groups in Jamf Pro

variable "groups" {
  description = "Map of computer groups to create"
  type = map(object({
    name        = string
    is_smart    = bool
    site_id     = optional(number, -1)
    criteria = optional(list(object({
      name         = string
      priority     = number
      and_or       = string
      search_type  = string
      value        = string
    })), [])
  }))
}

resource "jamfpro_computer_group" "groups" {
  for_each = var.groups

  name     = each.value.name
  is_smart = each.value.is_smart
  site_id  = each.value.site_id

  dynamic "criteria" {
    for_each = each.value.criteria
    content {
      name        = criteria.value.name
      priority    = criteria.value.priority
      and_or      = criteria.value.and_or
      search_type = criteria.value.search_type
      value       = criteria.value.value
    }
  }
}

output "group_ids" {
  description = "Map of group names to their IDs"
  value = {
    for k, v in jamfpro_computer_group.groups : k => v.id
  }
}

output "group_details" {
  description = "Complete details of created groups"
  value = {
    for k, v in jamfpro_computer_group.groups : k => {
      id       = v.id
      name     = v.name
      is_smart = v.is_smart
    }
  }
}
