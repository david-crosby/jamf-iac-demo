# Environment Variable Loading Guide

This guide explains how to properly load environment variables for local Terraform development.

## The Problem

Terraform needs environment variables to be prefixed with `TF_VAR_` to automatically map them to Terraform variables. The `.env` file uses `export` statements to properly set these in your shell.

## Quick Solution

### 1. Edit `.env` file with your credentials:

```bash
nano .env  # or vim, code, etc.
```

Add your actual Jamf Pro credentials:

```bash
export JAMF_URL="https://yourinstance.jamfcloud.com"
export JAMF_CLIENT_ID="abc123-your-client-id"
export JAMF_CLIENT_SECRET="your-secret-here"
export TF_VAR_jamf_url="$JAMF_URL"
export TF_VAR_jamf_client_id="$JAMF_CLIENT_ID"
export TF_VAR_jamf_client_secret="$JAMF_CLIENT_SECRET"
export TF_VAR_environment="dev"
```

### 2. Load the environment variables:

**For Bash/ZSH:**
```bash
source .env
# or
. .env
```

### 3. Verify variables are loaded:

```bash
# Run the verification script
./scripts/verify-env.sh

# Or manually check
echo $TF_VAR_jamf_url
echo $TF_VAR_jamf_client_id
```

### 4. Run Terraform:

```bash
cd terraform
terraform plan
```

## Automatic Loading (Recommended)

### Using direnv (Best Option)

Install direnv to automatically load `.env` when you enter the directory:

```bash
# Install direnv (macOS)
brew install direnv

# Add to your shell config
# For ZSH (add to ~/.zshrc):
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc

# For Bash (add to ~/.bashrc or ~/.bash_profile):
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc

# Reload shell
source ~/.zshrc  # or source ~/.bashrc

# Enable direnv for this directory
cd /path/to/jamf-iac-demo
echo 'dotenv' > .envrc
direnv allow
```

Now environment variables load automatically when you `cd` into the directory!

### Using ZSH Alias

Add to your `~/.zshrc`:

```bash
# Alias to load Jamf IaC environment
alias jamf-env='source ~/path/to/jamf-iac-demo/.env && echo "✅ Jamf environment loaded"'
```

Then just run:
```bash
jamf-env
```

### Using a Wrapper Script

Create `terraform-wrapper.sh`:

```bash
#!/bin/bash
source .env
cd terraform
terraform "$@"
```

Make it executable and use it:

```bash
chmod +x terraform-wrapper.sh
./terraform-wrapper.sh plan
./terraform-wrapper.sh apply
```

## Troubleshooting

### Problem: "No value for required variable"

**Symptom:**
```
Error: No value for required variable
│ 
│   on variables.tf line 1:
│    1: variable "jamf_url" {
│ 
│ The root module input variable "jamf_url" is not set
```

**Solution:**
```bash
# Verify .env has export statements
cat .env | grep export

# Load the environment
source .env

# Verify variables are set
./scripts/verify-env.sh

# Try Terraform again
cd terraform && terraform plan
```

### Problem: Variables are empty

**Symptom:**
```bash
echo $TF_VAR_jamf_url
# Returns nothing
```

**Solution:**
```bash
# Make sure you're using export in .env file
# WRONG:
JAMF_URL=https://example.com

# CORRECT:
export JAMF_URL="https://example.com"

# Reload after fixing
source .env
```

### Problem: Variables not persisting between shell sessions

**Symptom:**
Variables work in one terminal but not another.

**Solution:**
Use one of the automatic loading methods above (direnv recommended).

## Testing Your Setup

### Step-by-Step Test:

```bash
# 1. Load environment
source .env

# 2. Verify with helper script
./scripts/verify-env.sh

# 3. Test Jamf API connection
python3 scripts/test-jamf-connection.py

# 4. Test Terraform
cd terraform
terraform init
terraform plan

# 5. Should show a valid plan with no errors
```

### Expected Output:

```
✓ JAMF_URL is set (https://yourin...)
✓ JAMF_CLIENT_ID is set (abc123...)
✓ JAMF_CLIENT_SECRET is set (secret...)
✓ TF_VAR_jamf_url is set (https://yourin...)
✓ TF_VAR_jamf_client_id is set (abc123...)
✓ TF_VAR_jamf_client_secret is set (secret...)
✓ TF_VAR_environment is set (dev)

✅ All required environment variables are set!
```

## For Different Shells

### ZSH (macOS default)
```bash
source .env
```

### Bash
```bash
source .env
# or
. .env
```

### Fish Shell
```fish
# Fish uses different syntax, convert .env to fish format
# Or use bass plugin to source bash files
bass source .env
```

## Best Practices

1. **Never commit `.env`** - It's in `.gitignore` for a reason
2. **Use export statements** - Required for child processes (like Terraform)
3. **Use double quotes** - Prevents issues with special characters
4. **Use variable expansion** - `"$JAMF_URL"` syntax works properly
5. **Verify before running** - Always run `./scripts/verify-env.sh` first
6. **Use direnv** - Automates the process and prevents mistakes

## Alternative: terraform.tfvars (Not Recommended for Credentials)

You could use a `terraform.tfvars` file, but **this is NOT recommended for credentials**:

```hcl
# terraform/terraform.tfvars (DON'T USE FOR SECRETS!)
jamf_url = "https://yourinstance.jamfcloud.com"
# Don't put credentials here!
```

Instead, use environment variables (TF_VAR_*) for sensitive data.

## Quick Reference Card

```bash
# Load variables
source .env

# Verify loading
./scripts/verify-env.sh

# Check specific variable
echo $TF_VAR_jamf_url

# Run Terraform
cd terraform && terraform plan

# Auto-load with direnv
direnv allow
cd . # Re-enter directory to trigger load
```

## Getting Help

If variables still aren't loading:

1. Check `.env` file has `export` statements
2. Verify file isn't corrupted: `cat .env`
3. Test loading: `source .env && echo $JAMF_URL`
4. Run verification: `./scripts/verify-env.sh`
5. Check shell syntax (bash/zsh differences are minimal)

## Summary

The key points are:
- ✅ Use `export` in `.env` file
- ✅ Use `source .env` to load
- ✅ Verify with `./scripts/verify-env.sh`
- ✅ Use `direnv` for automatic loading
- ✅ Variables must have `TF_VAR_` prefix for Terraform

This approach keeps credentials secure and out of version control while making them available to Terraform.
