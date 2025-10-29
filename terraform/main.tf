# Example Jamf Pro Resources
# This file demonstrates basic Jamf Pro resource management with Terraform

# Example: Static Computer Group
resource "jamfpro_static_computer_group" "mac_fleet" {
  name        = "All Internal Managed Macs"
}

# Example: Smart Computer Group for macOS Sonoma
resource "jamfpro_smart_computer_group" "macos_sonoma" {
  name     = "macOS Sonoma Devices"

  criteria {
    name         = "Operating System Version"
    priority     = 0
    and_or       = "and"
    search_type  = "like"
    value        = "14"
  }

  criteria {
    name         = "Operating System"
    priority     = 1
    and_or       = "and"
    search_type  = "is"
    value        = "macOS"
  }
}

# Example: Category
resource "jamfpro_category" "security" {
  name     = "Security"
  priority = 10
}

# Example: Script
resource "jamfpro_script" "hello_world" {
  name           = "Hello World Example"
  script_contents = <<-EOT
    #!/bin/bash
    # Hello World Script
    echo "Hello from Terraform-managed Jamf Pro!"
    echo "Current user: $(whoami)"
    echo "Hostname: $(hostname)"
  EOT

  category_id = jamfpro_category.security.id
  info        = "Example script managed by Terraform"
  notes       = "Created as part of IaC demo"
  os_requirements = "13"
  priority    = "AFTER"
}

# Example: Policy (requires additional configuration)
# Uncomment and modify as needed
# resource "jamfpro_policy" "install_rosetta" {
#   name           = "Install Rosetta 2"
#   enabled        = true
#   trigger_checkin = true
#   frequency      = "Once per computer"
#   category_id    = jamfpro_category.security.id
#
#   scope {
#     computer_group_ids = [jamfpro_computer_group.macos_sonoma.id]
#   }
#
#   scripts {
#     script_id = jamfpro_script.install_rosetta.id
#     priority  = "After"
#   }
# }

# Example: Building
resource "jamfpro_building" "london_office" {
  name = "London Office"
  street_address1 = "123 Example Street"
  city = "London"
  country = "United Kingdom"
}

# Example: Department
resource "jamfpro_department" "engineering" {
  name = "Engineering"
}
