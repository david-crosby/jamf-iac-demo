# Jamf Pro Terraform Provider - Version Notes

## Current Provider Configuration

This repository uses the official Jamf Pro Terraform provider from Deployment Theory:

```hcl
terraform {
  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = "~> 0.20.0"
    }
  }
}

provider "jamfpro" {
  url           = var.jamf_url
  client_id     = var.jamf_client_id
  client_secret = var.jamf_client_secret
}
```

## Provider Details

- **Provider Name:** `jamfpro`
- **Source:** `deploymenttheory/jamfpro`
- **Version:** `~> 0.20.0` (0.20.x series)
- **Registry:** [Terraform Registry](https://registry.terraform.io/providers/deploymenttheory/jamfpro/latest/docs)
- **GitHub:** [deploymenttheory/terraform-provider-jamfpro](https://github.com/deploymenttheory/terraform-provider-jamfpro)

## Resource Naming Convention

All Jamf Pro resources use the `jamfpro_` prefix:

### Available Resources

**Common Resources:**
- `jamfpro_computer_group` - Computer groups (static and smart)
- `jamfpro_policy` - Policies
- `jamfpro_script` - Scripts
- `jamfpro_category` - Categories
- `jamfpro_building` - Buildings
- `jamfpro_department` - Departments
- `jamfpro_site` - Sites

**Configuration:**
- `jamfpro_macos_configuration_profile` - macOS configuration profiles
- `jamfpro_computer_extension_attribute` - Extension attributes
- `jamfpro_package` - Packages
- `jamfpro_dock_item` - Dock items

**Mobile Devices:**
- `jamfpro_mobile_device_configuration_profile` - Mobile device profiles
- `jamfpro_mobile_device_group` - Mobile device groups

**Advanced:**
- `jamfpro_account` - User accounts and groups
- `jamfpro_network_segment` - Network segments
- `jamfpro_api_role` - API roles
- `jamfpro_api_integration` - API integrations

For a complete list, see the [provider documentation](https://registry.terraform.io/providers/deploymenttheory/jamfpro/latest/docs).

## Example Resources

### Computer Group (Static)

```hcl
resource "jamfpro_computer_group" "mac_fleet" {
  name     = "All Managed Macs"
  is_smart = false
  site_id  = -1
}
```

### Computer Group (Smart)

```hcl
resource "jamfpro_computer_group" "macos_sonoma" {
  name     = "macOS Sonoma Devices"
  is_smart = true
  site_id  = -1

  criteria {
    name        = "Operating System Version"
    priority    = 0
    and_or      = "and"
    search_type = "like"
    value       = "14"
  }
}
```

### Script

```hcl
resource "jamfpro_script" "hello_world" {
  name           = "Hello World Example"
  script_content = <<-EOT
    #!/bin/bash
    echo "Hello from Terraform!"
  EOT
  category_id       = jamfpro_category.security.id
  info              = "Example script"
  os_requirements   = "macOS"
  priority          = "After"
}
```

### Policy

```hcl
resource "jamfpro_policy" "software_update" {
  name    = "Software Update"
  enabled = true
  
  general {
    trigger_checkin = true
    frequency       = "Once per computer"
    category_id     = jamfpro_category.security.id
  }
  
  scope {
    computer_group_ids = [jamfpro_computer_group.macos_sonoma.id]
  }
}
```

## Important Changes from Earlier Versions

If migrating from an older provider version, note these changes:

### Attribute Name Changes

Some attribute names have been standardised in v0.20.x:

**Computer Groups:**
- Criteria `search_value` → `value`
- Removed `description` field (not supported by API)

**General:**
- Provider name changed from `jamf` to `jamfpro`
- All resources use `jamfpro_` prefix instead of `jamf_`

### Migration Example

**Old (v0.1.x):**
```hcl
resource "jamf_computer_group" "example" {
  name        = "Example"
  description = "Example group"  # No longer supported
  
  criteria {
    search_value = "14"  # Old attribute name
  }
}
```

**New (v0.20.x):**
```hcl
resource "jamfpro_computer_group" "example" {
  name     = "Example"
  # description field removed
  
  criteria {
    value = "14"  # New attribute name
  }
}
```

## Provider Features

### Authentication Methods

The provider supports multiple authentication methods:

1. **Client Credentials (Recommended for CI/CD):**
   ```hcl
   provider "jamfpro" {
     url           = var.jamf_url
     client_id     = var.jamf_client_id
     client_secret = var.jamf_client_secret
   }
   ```

2. **Basic Authentication:**
   ```hcl
   provider "jamfpro" {
     url      = var.jamf_url
     username = var.jamf_username
     password = var.jamf_password
   }
   ```

3. **Environment Variables:**
   ```bash
   export JAMF_URL="https://yourinstance.jamfcloud.com"
   export JAMF_CLIENT_ID="your-client-id"
   export JAMF_CLIENT_SECRET="your-secret"
   ```

### Provider Configuration Options

```hcl
provider "jamfpro" {
  url           = var.jamf_url
  client_id     = var.jamf_client_id
  client_secret = var.jamf_client_secret
  
  # Optional: Custom timeout
  timeout = 30
  
  # Optional: Custom headers
  # custom_headers = {
  #   "X-Custom-Header" = "value"
  # }
}
```

## Version Constraints

Using version constraints ensures consistent behaviour:

```hcl
# Recommended: Allow patch updates only
version = "~> 0.20.0"  # Allows 0.20.x

# More permissive: Allow minor updates
version = "~> 0.20"    # Allows 0.20.x - 0.x.x

# Exact version (not recommended)
version = "= 0.20.0"   # Only 0.20.0

# Minimum version
version = ">= 0.20.0"  # 0.20.0 and above
```

## Upgrading the Provider

To upgrade to a newer version:

```bash
# Update versions.tf with new version constraint
# Then run:

cd terraform
terraform init -upgrade

# Review the changes
terraform plan

# Apply if everything looks good
terraform apply
```

## Known Limitations

### API Coverage
Not all Jamf Pro API endpoints are available in the provider. Check the [provider documentation](https://registry.terraform.io/providers/deploymenttheory/jamfpro/latest/docs) for supported resources.

### Read-Only Resources
Some resources may be read-only data sources rather than manageable resources.

### API Rate Limiting
The Jamf Pro API has rate limits. For large deployments, consider:
- Using smaller batches of changes
- Implementing retry logic
- Spreading operations over time

## Troubleshooting

### Provider Not Found

**Error:**
```
Error: Failed to query available provider packages
│ 
│ Could not retrieve the list of available versions for provider deploymenttheory/jamfpro
```

**Solution:**
```bash
# Clear the provider cache
rm -rf .terraform/
rm .terraform.lock.hcl

# Re-initialise
terraform init
```

### Authentication Errors

**Error:**
```
Error: authentication failed
```

**Solution:**
1. Verify credentials are correct
2. Check API client has required permissions
3. Ensure API client is enabled
4. Test with `curl`:
   ```bash
   curl -X POST "${JAMF_URL}/api/oauth/token" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "client_id=${CLIENT_ID}" \
     -d "client_secret=${CLIENT_SECRET}" \
     -d "grant_type=client_credentials"
   ```

### Resource Not Found

Some resources may not be available in your provider version. Check:
1. Provider version supports the resource
2. Resource name is correctly spelled (`jamfpro_*`)
3. Provider documentation for availability

## Getting Help

- **Provider Documentation:** https://registry.terraform.io/providers/deploymenttheory/jamfpro/latest/docs
- **GitHub Issues:** https://github.com/deploymenttheory/terraform-provider-jamfpro/issues
- **Jamf Pro API Docs:** https://developer.jamf.com/jamf-pro/docs
- **Community Forum:** https://community.jamf.com/

## Provider Changelog

To see what's new in each version:
- [GitHub Releases](https://github.com/deploymenttheory/terraform-provider-jamfpro/releases)
- [CHANGELOG.md](https://github.com/deploymenttheory/terraform-provider-jamfpro/blob/main/CHANGELOG.md)

## Contributing to the Provider

The Jamf Pro Terraform provider is open source and welcomes contributions:
- GitHub: https://github.com/deploymenttheory/terraform-provider-jamfpro
- Contribution guidelines available in the repository

## Summary

This repository is configured to use:
- ✅ Provider: `deploymenttheory/jamfpro`
- ✅ Version: `~> 0.20.0`
- ✅ Resource prefix: `jamfpro_`
- ✅ Authentication: OAuth2 Client Credentials
- ✅ All examples updated for v0.20.x compatibility

For the most up-to-date information, always refer to the [official provider documentation](https://registry.terraform.io/providers/deploymenttheory/jamfpro/latest/docs).
