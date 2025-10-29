# Environment Variable Fix Summary

## Problem Identified
The `.env` variables were not being passed to Terraform correctly. The original setup had environment variables without the `export` keyword, which meant they were only available in the current shell but not to child processes like Terraform.

## Root Cause
```bash
# ORIGINAL (INCORRECT):
JAMF_URL=https://example.com
TF_VAR_jamf_url=${JAMF_URL}  # This sets literal string "${JAMF_URL}", not the value
```

When you `source` a file with this syntax:
- Variables are set in the current shell
- The `${JAMF_URL}` expansion doesn't happen at assignment time
- Child processes (like Terraform) don't inherit the variables
- Terraform receives undefined variables

## Solutions Implemented

### 1. Fixed `.env.example` Template
Changed from:
```bash
JAMF_URL=https://example.com
TF_VAR_jamf_url=${JAMF_URL}
```

To:
```bash
export JAMF_URL="https://example.com"
export TF_VAR_jamf_url="$JAMF_URL"
```

**Why this works:**
- `export` makes variables available to child processes
- `"$JAMF_URL"` expands the variable at runtime
- Double quotes prevent issues with special characters
- Terraform can now read `TF_VAR_*` variables from the environment

### 2. Updated `setup-local.sh`
- Now creates `.env` file with proper `export` statements
- Added clear instructions about loading variables
- Added guidance for using direnv for automatic loading

### 3. Created `verify-env.sh` Script
New script that:
- Checks if all required environment variables are set
- Provides clear success/failure feedback
- Shows masked values for sensitive data
- Gives specific instructions if variables are missing

**Usage:**
```bash
./scripts/verify-env.sh
```

### 4. Created Comprehensive Documentation
Added three new documentation files:

**`docs/ENV-VARS-GUIDE.md`**
- Detailed explanation of environment variable loading
- Troubleshooting guide
- Multiple loading methods (direnv, aliases, wrapper scripts)
- Shell-specific instructions (bash/zsh/fish)
- Best practices

**`docs/QUICK-REFERENCE.txt`**
- Quick reference card for common tasks
- Can be printed or kept open in a terminal
- ZSH-specific aliases and tips
- Troubleshooting quick fixes

### 5. Updated Existing Documentation
Updated:
- `README.md` - Added prominent environment variable section
- `docs/QUICKSTART.md` - Made env var loading more explicit
- Both docs now emphasize the `export` requirement

## How to Use (Quick Version)

### One-Time Setup:
```bash
# 1. Run setup script
./scripts/setup-local.sh

# 2. Edit .env (ensure it has export statements)
nano .env

# 3. (Optional) Install direnv for automatic loading
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
echo 'dotenv' > .envrc
direnv allow
```

### Every Session (without direnv):
```bash
# Load variables
source .env

# Verify they're loaded
./scripts/verify-env.sh

# Now run Terraform
cd terraform && terraform plan
```

### With direnv (automatic):
```bash
# Just cd into the directory
cd jamf-iac-demo
# Variables automatically load! ✨
```

## Verification Process

To verify everything is working:

1. **Load environment:**
   ```bash
   source .env
   ```

2. **Run verification script:**
   ```bash
   ./scripts/verify-env.sh
   ```
   
   Should output:
   ```
   ✓ JAMF_URL is set
   ✓ JAMF_CLIENT_ID is set
   ✓ JAMF_CLIENT_SECRET is set
   ✓ TF_VAR_jamf_url is set
   ✓ TF_VAR_jamf_client_id is set
   ✓ TF_VAR_jamf_client_secret is set
   ✓ TF_VAR_environment is set
   ✅ All required environment variables are set!
   ```

3. **Test Terraform:**
   ```bash
   cd terraform
   terraform plan
   ```
   
   Should NOT show "No value for required variable" errors.

## Why This Approach?

### Alternative Approaches Considered:

1. **terraform.tfvars file**
   - ❌ Not suitable for credentials (would be in repo)
   - ❌ Still need to gitignore
   - ✅ Good for non-sensitive config

2. **Hardcoded in versions.tf**
   - ❌ Terrible security practice
   - ❌ Can't share repo
   - ❌ Credentials in version control

3. **Command-line flags**
   - ❌ Verbose and error-prone
   - ❌ Credentials visible in shell history
   - ❌ Not scriptable

4. **Environment variables with export (CHOSEN)**
   - ✅ Secure (not in repo)
   - ✅ Standard practice
   - ✅ Works with CI/CD
   - ✅ Can be automated with direnv
   - ✅ Shell-agnostic

## For Different Shells

### ZSH (macOS default since Catalina)
```bash
source .env
```
Works perfectly. No special configuration needed.

### Bash
```bash
source .env
# or
. .env
```
Identical behaviour to ZSH.

### Fish
```fish
# Fish uses different syntax
# Either convert .env to fish format, or:
bass source .env  # Requires bass plugin
```

## Best Practices Summary

1. ✅ **Always use `export`** in `.env` file
2. ✅ **Use double quotes** for variable values
3. ✅ **Use `source .env`** before running Terraform
4. ✅ **Verify with script** before working
5. ✅ **Use direnv** for automatic loading
6. ✅ **Never commit `.env`** file
7. ✅ **Keep `.env` in `.gitignore`**
8. ✅ **Use `TF_VAR_` prefix** for Terraform variables

## Troubleshooting

### Still getting "No value for required variable"?

1. Check `.env` syntax:
   ```bash
   cat .env | head -5
   ```
   Should show `export` at the start of each line.

2. Test variable loading:
   ```bash
   source .env
   echo $TF_VAR_jamf_url
   ```
   Should output your Jamf URL, not empty.

3. Run verification script:
   ```bash
   ./scripts/verify-env.sh
   ```
   All checks should pass.

4. Check Terraform can see variables:
   ```bash
   cd terraform
   terraform console
   > var.jamf_url
   ```
   Should output your Jamf URL.

### Variables work in one terminal but not another?

This is normal behaviour without direnv. Each shell session needs:
```bash
source .env
```

**Solution:** Install and configure direnv for automatic loading.

## What Changed in Each File

### Modified Files:
- `.env.example` - Added `export` statements
- `scripts/setup-local.sh` - Updated to create proper `.env` file
- `README.md` - Added environment variable section
- `docs/QUICKSTART.md` - Enhanced env var instructions

### New Files:
- `scripts/verify-env.sh` - Environment verification script
- `docs/ENV-VARS-GUIDE.md` - Comprehensive guide
- `docs/QUICK-REFERENCE.txt` - Quick reference card

## Testing Checklist

Before using the repository, verify:
- [ ] `.env` file has `export` statements
- [ ] Can load with `source .env`
- [ ] `./scripts/verify-env.sh` passes all checks
- [ ] `echo $TF_VAR_jamf_url` shows your URL
- [ ] `terraform plan` works without variable errors
- [ ] Can test connection with `python3 scripts/test-jamf-connection.py`

## Support

If you still have issues with environment variables:

1. Read `docs/ENV-VARS-GUIDE.md` for detailed help
2. Check `docs/QUICK-REFERENCE.txt` for quick fixes
3. Run `./scripts/verify-env.sh` to diagnose issues
4. Ensure you're using the updated `.env.example` as a template

## Summary

The fix ensures that:
- ✅ Environment variables are properly exported
- ✅ Terraform can access variables from the environment
- ✅ Variables persist for child processes
- ✅ Clear verification process exists
- ✅ Comprehensive documentation available
- ✅ Multiple loading methods supported (manual/automatic)
- ✅ Shell-specific guidance provided

The repository is now ready for use with proper environment variable handling!
