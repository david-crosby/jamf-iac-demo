# Jamf Pro Infrastructure as Code (IaC) Demo

A learning repository demonstrating CI/CD workflows for managing Jamf Pro tenants using Terraform and Infrastructure as Code principles.

## Overview

This repository provides a complete example of managing Jamf Pro configurations using:

- **Terraform** - Infrastructure as Code for Jamf Pro resources
- **GitHub Actions** - CI/CD pipeline automation
- **Release Please** - Automated semantic versioning and changelog generation
- **GitOps** - Pull request based workflow for changes

## Architecture

```
Developer → Branch → Pull Request → Code Review → Merge → Deploy to Jamf
```

### Workflow Process

1. Clone the repository locally
2. Create a feature branch using semantic commit conventions
3. Make changes to Terraform configurations
4. Push branch and create a Pull Request
5. PR triggers validation (terraform plan, linting)
6. After approval and merge to main, changes automatically apply to Jamf tenant
7. Release Please creates release PRs when using conventional commits

## Prerequisites

### Local Development
- macOS (recommended)
- Python 3.9+ with `uv` for package management
- Terraform >= 1.5.0
- Git
- GitHub CLI (`gh`) - optional but recommended

### Jamf Pro Requirements
- Jamf Pro tenant (cloud or on-premises)
- API client credentials with appropriate permissions
- API endpoint URL

### GitHub Requirements
- GitHub repository with Actions enabled
- Repository secrets configured (see Setup section)

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── terraform-pr.yml          # PR validation workflow
│       ├── terraform-apply.yml       # Deployment workflow
│       └── release-please.yml        # Release automation
├── terraform/
│   ├── modules/                      # Reusable Terraform modules
│   │   ├── computer-groups/
│   │   ├── policies/
│   │   └── scripts/
│   ├── environments/
│   │   ├── dev/                      # Development environment
│   │   └── prod/                     # Production environment
│   ├── main.tf                       # Main Terraform configuration
│   ├── variables.tf                  # Variable definitions
│   ├── outputs.tf                    # Output definitions
│   └── versions.tf                   # Provider version constraints
├── scripts/
│   └── setup-local.sh               # Local environment setup script
├── docs/
│   └── CONTRIBUTING.md              # Contribution guidelines
├── .release-please-manifest.json    # Release Please manifest
├── release-please-config.json       # Release Please configuration
└── README.md                        # This file
```

## Setup

### 1. Repository Secrets

Configure the following secrets in your GitHub repository (Settings → Secrets and variables → Actions):

| Secret Name | Description | Example |
|------------|-------------|---------|
| `JAMF_INSTANCE_FQDN` | Your Jamf Pro FQDN (without https://) | `yourinstance.jamfcloud.com` |
| `JAMF_CLIENT_ID` | API client ID | `abcd1234-5678-90ef-ghij-klmnopqrstuv` |
| `JAMF_CLIENT_SECRET` | API client secret | `xyz...` |
| `TERRAFORM_CLOUD_TOKEN` | Terraform Cloud API token (optional) | `xxx.atlasv1.yyy...` |

**IMPORTANT:** Enter your Jamf FQDN WITHOUT the `https://` protocol.  
✅ Correct: `yourinstance.jamfcloud.com`  
❌ Incorrect: `https://yourinstance.jamfcloud.com`

### 2. Local Development Setup

Clone the repository and set up your local environment:

```bash
# Clone the repository
git clone https://github.com/yourusername/jamf-iac-demo.git
cd jamf-iac-demo

# Run the setup script (creates .env file template)
chmod +x scripts/setup-local.sh
./scripts/setup-local.sh

# Edit .env with your credentials (never commit this file!)
nano .env

# IMPORTANT: Load the environment variables
source .env

# Verify variables are loaded correctly
./scripts/verify-env.sh

# Initialise Terraform
cd terraform
terraform init
```

### 3. Environment Variables - CRITICAL STEP ⚠️

The `.env` file **must** use `export` statements for Terraform to access the variables:

```bash
# Your .env file should look like this:
export JAMF_INSTANCE_FQDN="yourinstance.jamfcloud.com"
export JAMF_AUTH_METHOD="oauth2"
export JAMF_CLIENT_ID="your-client-id"
export JAMF_CLIENT_SECRET="your-client-secret"
export TF_VAR_jamf_instance_fqdn="$JAMF_INSTANCE_FQDN"
export TF_VAR_jamf_auth_method="$JAMF_AUTH_METHOD"
export TF_VAR_jamf_client_id="$JAMF_CLIENT_ID"
export TF_VAR_jamf_client_secret="$JAMF_CLIENT_SECRET"
export TF_VAR_environment="dev"
```

**CRITICAL NOTES:**
- Enter your Jamf FQDN **WITHOUT** the `https://` protocol
- ✅ Correct: `yourinstance.jamfcloud.com`
- ❌ Incorrect: `https://yourinstance.jamfcloud.com`
- Authentication method should be `oauth2` for API client credentials

**Before running Terraform, always:**
```bash
source .env
./scripts/verify-env.sh  # Confirms variables are loaded
```

**Tip:** Install `direnv` to automatically load `.env` when entering the directory:
```bash
brew install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
echo 'dotenv' > .envrc
direnv allow
```

For detailed instructions, see [Environment Variables Guide](docs/ENV-VARS-GUIDE.md).

### 4. Configure Terraform Backend (Optional)

For team collaboration, configure a remote backend in `terraform/versions.tf`:

```hcl
terraform {
  backend "s3" {
    # or use Terraform Cloud
  }
}
```

## Making Changes

### Semantic Commit Convention

This repository uses [Conventional Commits](https://www.conventionalcommits.org/). Your commit messages should follow this format:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature (triggers minor version bump)
- `fix`: Bug fix (triggers patch version bump)
- `docs`: Documentation changes
- `chore`: Maintenance tasks
- `refactor`: Code refactoring
- `test`: Adding tests
- `ci`: CI/CD changes

**Breaking changes:** Add `!` after type or include `BREAKING CHANGE:` in footer (triggers major version bump)

### Example Workflow

```bash
# Create a feature branch
git checkout -b feat/add-new-computer-group

# Make your changes to Terraform files
cd terraform
# Edit files...

# Test locally (optional but recommended)
terraform plan

# Commit with semantic message
git add .
git commit -m "feat(groups): add macOS developer computer group

Add a new smart group for macOS developers with criteria for OS version and department"

# Push and create PR
git push origin feat/add-new-computer-group
gh pr create --title "feat(groups): add macOS developer computer group" \
             --body "Adds a new smart group for tracking macOS developer machines"
```

### Pull Request Process

1. **Automated Checks Run:**
   - Terraform format validation
   - Terraform plan (shows proposed changes)
   - Security scanning (optional)

2. **Code Review:**
   - Review the Terraform plan output
   - Ensure changes follow IaC best practices
   - Approve the PR

3. **Merge:**
   - Squash and merge to main (recommended)
   - This triggers the deployment workflow

4. **Automatic Deployment:**
   - Terraform apply runs automatically
   - Changes are applied to Jamf Pro tenant
   - Deployment status is reported in the Actions tab

## Release Management

Release Please monitors commits on the main branch and automatically:

1. Creates a release PR when semantic commits are detected
2. Updates CHANGELOG.md with all changes
3. Bumps version numbers appropriately
4. Creates GitHub releases when the release PR is merged

## Terraform Provider: Jamf Pro

This project uses the official Jamf Pro Terraform provider (version 0.20.x). Key resources you can manage:

- Computer groups (static and smart)
- Policies
- Configuration profiles
- Scripts
- Extension attributes
- Categories
- Buildings, departments, sites
- macOS configuration profiles
- Packages
- And much more...

Example provider configuration:

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
  jamfpro_instance_fqdn            = var.jamf_instance_fqdn
  auth_method                       = var.jamf_auth_method
  client_id                         = var.jamf_client_id
  client_secret                     = var.jamf_client_secret
  jamfpro_load_balancer_lock        = true
  mandatory_request_delay_milliseconds = 100
}
```

**Important Configuration Notes:**
- `jamfpro_instance_fqdn` should be the FQDN only (e.g., `yourinstance.jamfcloud.com`)
- `auth_method` should be set to `"oauth2"` for API client credentials
- `jamfpro_load_balancer_lock` set to `true` improves reliability
- `mandatory_request_delay_milliseconds` helps prevent API rate limiting

For full documentation, see the [Jamf Pro Terraform Provider Registry](https://registry.terraform.io/providers/deploymenttheory/jamfpro/latest/docs).

## Best Practices

### Security
- Never commit credentials or secrets
- Use GitHub repository secrets for sensitive data
- Limit Jamf API client permissions to only what's needed
- Review all Terraform plans before approving PRs

### Terraform
- Use modules for reusable components
- Keep state file secure (use remote backend)
- Use variables for environment-specific values
- Add meaningful descriptions to all resources

### Git Workflow
- Always work in feature branches
- Use semantic commit messages
- Keep commits atomic and focused
- Squash commits when merging PRs

## Troubleshooting

### Terraform Plan Fails in PR
- Check that repository secrets are configured correctly
- Verify Jamf API credentials have necessary permissions
- Review the Actions logs for specific error messages

### Deployment Stuck
- Check the Actions tab for failed steps
- Verify Jamf Pro is accessible from GitHub Actions runners
- Check for state lock issues if using remote backend

### Local Development Issues
- Ensure `.env` file is properly configured
- Run `terraform init` if providers are outdated
- Check Terraform version compatibility

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for detailed contribution guidelines.

## Resources

- [Jamf Pro API Documentation](https://developer.jamf.com/jamf-pro/docs/jamf-pro-api-overview)
- [Terraform Jamf Provider](https://registry.terraform.io/providers/deploymenttheory/jamf/latest/docs)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Release Please](https://github.com/googleapis/release-please)

## Licence

MIT Licence - See LICENCE file for details

## Support

For issues or questions:
- Open a GitHub issue
- Check existing issues and discussions
- Review the documentation in the `/docs` directory
