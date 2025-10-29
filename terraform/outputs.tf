output "computer_groups" {
  description = "Computer groups managed by Terraform"
  value = {
    mac_fleet = {
      id   = jamfpro_static_computer_group.mac_fleet.id
      name = jamfpro_static_computer_group.mac_fleet.name
    }
    macos_sonoma = {
      id   = jamfpro_smart_computer_group.macos_sonoma.id
      name = jamfpro_smart_computer_group.macos_sonoma.name
    }
  }
}

output "categories" {
  description = "Categories managed by Terraform"
  value = {
    security = {
      id   = jamfpro_category.security.id
      name = jamfpro_category.security.name
    }
  }
}

output "scripts" {
  description = "Scripts managed by Terraform"
  value = {
    hello_world = {
      id   = jamfpro_script.hello_world.id
      name = jamfpro_script.hello_world.name
    }
  }
}

output "buildings" {
  description = "Buildings managed by Terraform"
  value = {
    london_office = {
      id   = jamfpro_building.london_office.id
      name = jamfpro_building.london_office.name
    }
  }
}

output "departments" {
  description = "Departments managed by Terraform"
  value = {
    engineering = {
      id   = jamfpro_department.engineering.id
      name = jamfpro_department.engineering.name
    }
  }
}
