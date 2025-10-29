# Quick Start Guide

Get up and running with Jamf Pro Infrastructure as Code in 10 minutes.

## Prerequisites

- GitHub account
- Jamf Pro tenant with admin access
- macOS with Homebrew (or Linux/Windows with appropriate package managers)

## Step 1: Install Required Tools (5 minutes)

### macOS

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Terraform
brew install terraform

# Install Python 3
brew install python3

# Install uv (faster Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install GitHub CLI (optional but recommended)
brew install gh
```

### Verify installations

```bash
terraform version  # Should show 1.5.0+
python3 --version  # Should show 3.9+
uv --version       # Should show latest version
```

## Step 2: Set Up Jamf Pro API Client (2 minutes)

1. Log in to your Jamf Pro instance
2. Navigate to **Settings** → **System** → **API Roles and Clients**
3. Click **New** to create a new API client
4. Configure the API client:
   - **Display Name**: Terraform CI/CD
   - **Enabled**: Yes
   - **Access Token Lifetime**: 1800 seconds (or as required)
5. Assign the following privileges (minimum required):
   - Read: All objects you want to manage
   - Create: All objects you want to create
   - Update: All objects you want to modify
   - Delete: (optional) Only if you need to delete resources
6. Click **Save**
7. **Important**: Copy the **Client ID** and **Client Secret** immediately (you won't see the secret again!)

## Step 3: Fork and Clone the Repository (1 minute)

```bash
# Fork the repository on GitHub (using the web interface or gh CLI)
gh repo fork YOUR_ORG/jamf-iac-demo --clone

# Or clone directly
git clone https://github.com/YOUR_USERNAME/jamf-iac-demo.git
cd jamf-iac-demo
```

## Step 4: Configure Local Environment (1 minute)

```bash
# Run the setup script
chmod +x scripts/setup-local.sh
./scripts/setup-local.sh

# Edit the .env file with your credentials
nano .env  # or use your preferred editor
```

**CRITICAL:** Update `.env` with your Jamf Pro details and ensure you use `export` statements:

```bash
export JAMF_URL="https://yourinstance.jamfcloud.com"
export JAMF_CLIENT_ID="your-client-id"
export JAMF_CLIENT_SECRET="your-client-secret"
export TF_VAR_jamf_url="$JAMF_URL"
export TF_VAR_jamf_client_id="$JAMF_CLIENT_ID"
export TF_VAR_jamf_client_secret="$JAMF_CLIENT_SECRET"
export TF_VAR_environment="dev"
```

**Then load the variables:**
```bash
# Load environment variables (REQUIRED!)
source .env

# Verify they're loaded
./scripts/verify-env.sh
```

You should see:
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

## Step 5: Initialise Terraform (30 seconds)

```bash
cd terraform
terraform init
```

You should see:
```
Terraform has been successfully initialised!
```

You'll see the Jamf Pro provider (v0.20.x) has been downloaded.

## Step 6: Test Your Configuration (30 seconds)

```bash
# See what Terraform would create
terraform plan
```

Review the plan output. It should show the example resources that will be created (groups, scripts, categories, etc.).

## Step 7: Apply Changes (Optional - 30 seconds)

**Warning**: This will create resources in your Jamf Pro tenant!

```bash
# Apply the changes
terraform apply

# Type 'yes' when prompted
```

## Step 8: Configure GitHub Repository Secrets (1 minute)

For CI/CD to work, add these secrets to your GitHub repository:

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add:
   - `JAMF_URL`: Your Jamf Pro URL
   - `JAMF_CLIENT_ID`: Your API client ID
   - `JAMF_CLIENT_SECRET`: Your API client secret

## Step 9: Make Your First Change (2 minutes)

```bash
# Create a new branch
git checkout -b feat/add-test-group

# Edit terraform/main.tf to add a new group
# Add this at the end of the file:
cat >> terraform/main.tf << 'EOF'

resource "jamfpro_computer_group" "test_group" {
  name     = "My First Terraform Group"
  is_smart = false
}
EOF

# Commit using semantic format
git add terraform/main.tf
git commit -m "feat(groups): add test computer group"

# Push and create PR
git push origin feat/add-test-group
gh pr create --title "feat(groups): add test computer group" \
             --body "Adding my first computer group via Terraform"
```

## Step 10: Watch the Magic Happen! ✨

1. Go to your GitHub repository
2. Check the **Pull Requests** tab
3. You'll see your PR with automated checks running:
   - ✅ Terraform format validation
   - ✅ Terraform plan (showing what will be created)
   - ✅ Security scan
4. Review the Terraform plan in the PR comments
5. Merge the PR
6. Go to the **Actions** tab and watch the deployment happen
7. Check your Jamf Pro tenant - your new group should appear!

## What's Next?

### Learn the Workflow

- Read [CONTRIBUTING.md](docs/CONTRIBUTING.md) for detailed guidelines
- Study the example resources in `terraform/main.tf`
- Explore the modules in `terraform/modules/`

### Customise for Your Needs

- Modify example resources to match your environment
- Add new policies, scripts, or configuration profiles
- Create custom modules for repeated patterns

### Advanced Topics

- Set up Terraform Cloud for state management
- Configure Slack notifications
- Add custom validation scripts
- Implement multi-environment setups (dev/staging/prod)

## Troubleshooting

### "No value for required variable" error
**Problem:** Terraform says variables are not set

**Solution:**
```bash
# 1. Check your .env file has export statements
cat .env | grep export

# 2. Load the environment
source .env

# 3. Verify variables
./scripts/verify-env.sh

# 4. Check a specific variable
echo $TF_VAR_jamf_url

# 5. If empty, your .env file needs export statements:
# WRONG: JAMF_URL=https://example.com
# RIGHT: export JAMF_URL="https://example.com"
```

**Pro Tip:** Install direnv to auto-load variables:
```bash
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc
echo 'dotenv' > .envrc
direnv allow
```

See [Environment Variables Guide](ENV-VARS-GUIDE.md) for detailed help.

### "Invalid credentials" error
- Verify your API client credentials in `.env`
- Ensure the API client has sufficient permissions
- Check that the client is enabled in Jamf Pro

### Terraform init fails
- Check your internet connection
- Verify Terraform is installed correctly
- Try `terraform init -upgrade`

### PR checks fail
- Ensure repository secrets are configured
- Check the Actions logs for specific errors
- Verify your Terraform syntax: `terraform validate`

### Can't authenticate with Jamf
- Confirm your Jamf Pro URL is correct (include https://)
- Test API access with curl:
  ```bash
  curl -X POST "${JAMF_URL}/api/oauth/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=${JAMF_CLIENT_ID}" \
    -d "client_secret=${JAMF_CLIENT_SECRET}" \
    -d "grant_type=client_credentials"
  ```

## Getting Help

- **Documentation**: Check the README.md
- **Issues**: Open a GitHub issue
- **Discussions**: Use GitHub Discussions
- **Jamf Provider Docs**: https://registry.terraform.io/providers/deploymenttheory/jamf/latest/docs

## Success! 🎉

You now have a working CI/CD pipeline for managing Jamf Pro with Infrastructure as Code! Every change goes through:

1. Branch creation
2. Pull request with automated validation
3. Code review
4. Merge to main
5. Automatic deployment to Jamf Pro

Welcome to the world of GitOps! 🚀
