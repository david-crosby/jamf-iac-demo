# Computer Groups Module

This module simplifies the creation of multiple computer groups in Jamf Pro.

## Usage

```hcl
module "computer_groups" {
  source = "./modules/computer-groups"

  groups = {
    all_macs = {
      name     = "All Managed Macs"
      is_smart = false
    }
    
    macos_sonoma = {
      name     = "macOS Sonoma Devices"
      is_smart = true
      criteria = [
        {
          name        = "Operating System Version"
          priority    = 0
          and_or      = "and"
          search_type = "like"
          value       = "14"
        }
      ]
    }
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| groups | Map of computer groups to create | map(object) | Yes |

## Outputs

| Name | Description |
|------|-------------|
| group_ids | Map of group names to their IDs |
| group_details | Complete details of created groups |

## Examples

### Static Group

```hcl
groups = {
  test_devices = {
    name     = "Test Devices"
    is_smart = false
  }
}
```

### Smart Group with Multiple Criteria

```hcl
groups = {
  engineering_macs = {
    name     = "Engineering macOS Devices"
    is_smart = true
    criteria = [
      {
        name        = "Department"
        priority    = 0
        and_or      = "and"
        search_type = "is"
        value       = "Engineering"
      },
      {
        name        = "Operating System"
        priority    = 1
        and_or      = "and"
        search_type = "is"
        value       = "macOS"
      }
    ]
  }
}
```
