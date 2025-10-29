# Provider Update Summary - October 2024

## Changes Made

The repository has been updated to use the correct Jamf Pro Terraform provider configuration.

## What Changed

### 1. Provider Configuration

**Before:**
```hcl
terraform {
  required_providers {
    jamf = {
      source  = "deploymenttheory/jamf"
      version = "~> 0.1"
    }
  }
}

provider "jamf" {
  url           = var.jamf_url
  client_id     = var.jamf_client_id
  client_secret = var.jamf_client_secret
}
```

**After:**
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

### 2. Resource Name Changes

All resources updated from `jamf_*` to `jamfpro_*`:

| Old Resource Name | New Resource Name |
|------------------|-------------------|
| `jamf_computer_group` | `jamfpro_computer_group` |
| `jamf_category` | `jamfpro_category` |
| `jamf_script` | `jamfpro_script` |
| `jamf_policy` | `jamfpro_policy` |
| `jamf_building` | `jamfpro_building` |
| `jamf_department` | `jamfpro_department` |

### 3. Attribute Changes

**Computer Groups - Criteria:**
- `search_value` → `value`

**Computer Groups - Removed:**
- `description` field (not supported by current API)

### 4. Files Updated

**Terraform Configuration:**
- ✅ `terraform/versions.tf` - Provider and version
- ✅ `terraform/main.tf` - All resource definitions
- ✅ `terraform/outputs.tf` - All output references
- ✅ `terraform/modules/computer-groups/main.tf` - Module resources
- ✅ `terraform/modules/computer-groups/README.md` - Module examples

**Documentation:**
- ✅ `README.md` - Provider section updated
- ✅ `docs/QUICKSTART.md` - Examples updated
- ✅ `docs/OVERVIEW.md` - Provider version noted
- ✅ `docs/SETUP-CHECKLIST.md` - Test examples updated
- ✅ `docs/QUICK-REFERENCE.txt` - Provider link updated
- ✅ `docs/PROVIDER-NOTES.md` - **NEW** comprehensive provider guide

## Migration Guide

If you've already initialised Terraform with the old provider:

### Step 1: Update Configuration Files
All files have been updated in this repository. If you're migrating an existing deployment:

```bash
# Backup your state
cp terraform.tfstate terraform.tfstate.backup

# Update your .tf files with the new resource names
# (Already done in this repository)
```

### Step 2: Remove Old Provider
```bash
cd terraform
rm -rf .terraform/
rm .terraform.lock.hcl
```

### Step 3: Reinitialise
```bash
terraform init
```

### Step 4: State Migration (If Needed)
If you have existing resources managed by the old provider:

```bash
# For each resource, move from old to new name
terraform state mv jamf_computer_group.mac_fleet jamfpro_computer_group.mac_fleet
terraform state mv jamf_category.security jamfpro_category.security
# ... repeat for all resources
```

### Step 5: Verify
```bash
terraform plan
```

Should show no changes if migration was successful.

## New Provider Benefits

### Version 0.20.0+ Features:
- ✅ More stable API
- ✅ Better error handling
- ✅ Expanded resource coverage
- ✅ Improved documentation
- ✅ Active development and support
- ✅ Regular updates

### Supported Resources (0.20.x):
- Computer management (groups, extension attributes)
- Policy management
- Script management
- Configuration profiles (macOS and iOS)
- Package management
- User and group management
- Site and building management
- Network segments
- API roles and integrations
- And more...

## Compatibility Notes

### Minimum Requirements:
- Terraform >= 1.5.0
- Jamf Pro 10.45.0 or later (recommended)
- Valid API client credentials

### Breaking Changes from v0.1.x:
1. Provider name changed (`jamf` → `jamfpro`)
2. Resource names changed (`jamf_*` → `jamfpro_*`)
3. Some attribute names standardised
4. Removed unsupported attributes

## Testing Your Setup

After updating, verify everything works:

```bash
# 1. Load environment
source .env

# 2. Verify environment
./scripts/verify-env.sh

# 3. Initialise with new provider
cd terraform
terraform init

# 4. Validate configuration
terraform validate

# 5. Check plan
terraform plan

# 6. Test Jamf connection
cd ..
python3 scripts/test-jamf-connection.py
```

## Documentation

Comprehensive provider documentation available at:
- **Registry:** https://registry.terraform.io/providers/deploymenttheory/jamfpro/latest/docs
- **GitHub:** https://github.com/deploymenttheory/terraform-provider-jamfpro
- **Local:** See `docs/PROVIDER-NOTES.md` for detailed information

## Example Usage

### Computer Group
```hcl
resource "jamfpro_computer_group" "example" {
  name     = "Example Group"
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
resource "jamfpro_script" "example" {
  name           = "Example Script"
  script_content = file("${path.module}/scripts/example.sh")
  category_id    = jamfpro_category.security.id
  os_requirements = "macOS"
  priority       = "After"
}
```

### Policy
```hcl
resource "jamfpro_policy" "example" {
  name    = "Example Policy"
  enabled = true
  
  general {
    trigger_checkin = true
    frequency       = "Once per computer"
  }
  
  scope {
    computer_group_ids = [jamfpro_computer_group.example.id]
  }
}
```

## Troubleshooting

### Provider Download Issues
```bash
# Clear cache and retry
rm -rf .terraform/ .terraform.lock.hcl
terraform init
```

### State Migration Issues
```bash
# Check current state
terraform state list

# Show specific resource
terraform state show jamfpro_computer_group.mac_fleet
```

### Attribute Errors
If you see errors about unknown attributes:
1. Check `docs/PROVIDER-NOTES.md` for attribute changes
2. Consult provider documentation
3. Update affected resources

## Getting Help

If you encounter issues:

1. **Check Documentation:**
   - `docs/PROVIDER-NOTES.md` - Local provider guide
   - Provider registry documentation
   - This repository's README.md

2. **Verify Setup:**
   - Run `./scripts/verify-env.sh`
   - Test with `terraform validate`
   - Check provider version: `terraform version`

3. **Common Solutions:**
   - Ensure using v0.20.x provider
   - Verify all resource names use `jamfpro_` prefix
   - Check attribute names match current schema
   - Confirm credentials are valid

4. **Get Support:**
   - Provider issues: GitHub Issues
   - Repository issues: Your repo issues
   - Jamf API: developer.jamf.com

## Summary

✅ **Provider updated:** `deploymenttheory/jamfpro` v0.20.x  
✅ **All resources updated:** Using `jamfpro_*` prefix  
✅ **Attributes standardised:** Following v0.20.x schema  
✅ **Documentation updated:** All guides reflect changes  
✅ **Examples updated:** Ready to use  
✅ **Backwards compatible:** With proper migration  

The repository is now using the current, actively maintained Jamf Pro Terraform provider with the latest features and improvements!

---

**Last Updated:** October 2024  
**Provider Version:** 0.20.0+  
**Repository Version:** 1.0.0
