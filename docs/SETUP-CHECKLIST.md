# Repository Setup Checklist

Use this checklist to ensure your Jamf Pro IaC repository is properly configured.

## Prerequisites Setup

### Local Machine
- [ ] macOS (or Linux/Windows with appropriate tools)
- [ ] Homebrew installed (macOS)
- [ ] Git installed and configured
  ```bash
  git --version
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"
  ```
- [ ] Terraform >= 1.5.0 installed
  ```bash
  terraform version
  ```
- [ ] Python 3.9+ installed
  ```bash
  python3 --version
  ```
- [ ] uv installed (preferred Python package manager)
  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```
- [ ] GitHub CLI installed (optional but recommended)
  ```bash
  brew install gh
  gh auth login
  ```

### Jamf Pro Access
- [ ] Jamf Pro tenant (cloud or on-premises)
- [ ] Admin access to Jamf Pro
- [ ] Jamf Pro URL noted (e.g., https://yourinstance.jamfcloud.com)

## Jamf Pro API Configuration

- [ ] Log in to Jamf Pro as admin
- [ ] Navigate to Settings → System → API Roles and Clients
- [ ] Create new API Role with required permissions:
  - [ ] Computer Groups: Read, Create, Update, Delete
  - [ ] Policies: Read, Create, Update, Delete
  - [ ] Scripts: Read, Create, Update, Delete
  - [ ] Categories: Read, Create, Update, Delete
  - [ ] Configuration Profiles: Read, Create, Update, Delete
  - [ ] Buildings: Read, Create, Update, Delete
  - [ ] Departments: Read, Create, Update, Delete
  - [ ] (Add other resources as needed)
- [ ] Create new API Client
  - [ ] Display Name: "Terraform CI/CD"
  - [ ] Enabled: Yes
  - [ ] Access Token Lifetime: 1800 seconds (or as needed)
  - [ ] Assign the API Role created above
- [ ] Save and copy Client ID
- [ ] Save and copy Client Secret (shown only once!)
- [ ] Store credentials securely (password manager)

## GitHub Repository Setup

### Repository Creation
- [ ] Fork or create new repository from template
- [ ] Clone repository locally
  ```bash
  git clone https://github.com/YOUR_USERNAME/jamf-iac-demo.git
  cd jamf-iac-demo
  ```
- [ ] Verify all files are present
  ```bash
  ls -la
  ```

### Repository Secrets Configuration
- [ ] Go to GitHub repository Settings
- [ ] Navigate to Secrets and variables → Actions
- [ ] Add repository secret: `JAMF_URL`
  - Value: Your Jamf Pro URL (e.g., https://yourinstance.jamfcloud.com)
- [ ] Add repository secret: `JAMF_CLIENT_ID`
  - Value: Your API Client ID
- [ ] Add repository secret: `JAMF_CLIENT_SECRET`
  - Value: Your API Client Secret
- [ ] (Optional) Add repository secret: `SLACK_WEBHOOK_URL`
  - For deployment notifications
- [ ] Verify secrets are saved correctly

### Branch Protection Rules
- [ ] Go to Settings → Branches
- [ ] Add branch protection rule for `main`
  - [ ] Require pull request reviews before merging
  - [ ] Require status checks to pass before merging
    - [ ] terraform-check
    - [ ] security-scan
    - [ ] commit-validation
  - [ ] Require conversation resolution before merging
  - [ ] Require linear history (squash merge)
  - [ ] Do not allow force pushes
  - [ ] Do not allow deletions
- [ ] Save protection rule

### GitHub Actions Configuration
- [ ] Go to Settings → Actions → General
- [ ] Workflow permissions:
  - [ ] Set to "Read and write permissions"
  - [ ] Allow GitHub Actions to create and approve pull requests
- [ ] Save settings

### Environment Configuration (Optional but Recommended)
- [ ] Go to Settings → Environments
- [ ] Create new environment: `production`
  - [ ] Add protection rules:
    - [ ] Required reviewers (optional)
    - [ ] Wait timer (optional)
  - [ ] Add environment secrets (same as repository secrets)
- [ ] Save environment

## Local Development Setup

### Environment Configuration
- [ ] Run setup script
  ```bash
  chmod +x scripts/setup-local.sh
  ./scripts/setup-local.sh
  ```
- [ ] Edit `.env` file
  ```bash
  nano .env  # or use your preferred editor
  ```
- [ ] Add your Jamf Pro credentials to `.env`:
  ```bash
  JAMF_URL=https://yourinstance.jamfcloud.com
  JAMF_CLIENT_ID=your-client-id-here
  JAMF_CLIENT_SECRET=your-client-secret-here
  ```
- [ ] Save `.env` file
- [ ] Verify `.env` is in `.gitignore`
  ```bash
  grep .env .gitignore
  ```

### Terraform Initialisation
- [ ] Load environment variables
  ```bash
  source .env
  ```
- [ ] Navigate to Terraform directory
  ```bash
  cd terraform
  ```
- [ ] Initialise Terraform
  ```bash
  terraform init
  ```
- [ ] Verify initialisation succeeded
- [ ] Format Terraform files
  ```bash
  terraform fmt -recursive
  ```
- [ ] Validate configuration
  ```bash
  terraform validate
  ```

### Connection Testing
- [ ] Test Jamf Pro API connectivity
  ```bash
  cd ..
  python3 scripts/test-jamf-connection.py
  ```
- [ ] Verify all tests pass
- [ ] Review Jamf Pro version information

### Terraform Planning
- [ ] Run Terraform plan
  ```bash
  cd terraform
  terraform plan
  ```
- [ ] Review planned changes
- [ ] Ensure no unexpected resources will be created/modified/destroyed

## Optional: Initial Apply (Test Environment)

**Warning:** This will create resources in your Jamf Pro tenant!

- [ ] Review the plan output carefully
- [ ] Ensure you're working in a test/dev environment
- [ ] Apply changes
  ```bash
  terraform apply
  ```
- [ ] Type `yes` when prompted
- [ ] Verify resources created in Jamf Pro UI
- [ ] Check Terraform outputs
  ```bash
  terraform output
  ```

## Testing the CI/CD Pipeline

### Create Test Branch
- [ ] Create feature branch
  ```bash
  git checkout -b feat/test-cicd-pipeline
  ```
- [ ] Make a small test change
  ```bash
  # Add a test resource to terraform/main.tf
  cat >> terraform/main.tf << 'EOF'

  # Test resource for CI/CD validation
  resource "jamfpro_category" "test_cicd" {
    name     = "CI/CD Test"
    priority = 5
  }
  EOF
  ```
- [ ] Format Terraform
  ```bash
  terraform fmt
  ```
- [ ] Commit changes with semantic message
  ```bash
  git add .
  git commit -m "feat(test): add test category for CI/CD validation"
  ```

### Push and Create PR
- [ ] Push branch to GitHub
  ```bash
  git push origin feat/test-cicd-pipeline
  ```
- [ ] Create Pull Request
  ```bash
  gh pr create --title "feat(test): add test category for CI/CD validation" \
               --body "Testing the CI/CD pipeline with a test category"
  ```
- [ ] Or create PR via GitHub web interface

### Verify PR Checks
- [ ] Go to Pull Request on GitHub
- [ ] Verify all checks are running:
  - [ ] Terraform Format Check
  - [ ] Terraform Initialisation
  - [ ] Terraform Validation
  - [ ] Terraform Plan
  - [ ] Security Scan
  - [ ] Commit Validation
- [ ] Review Terraform plan in PR comments
- [ ] Verify plan shows expected changes
- [ ] Check for any errors or warnings

### Merge and Deploy
- [ ] Approve the PR (if not self-approving, have someone review)
- [ ] Merge the PR (use "Squash and merge")
- [ ] Go to Actions tab
- [ ] Verify "Terraform Apply" workflow runs
- [ ] Check deployment status
- [ ] Verify resource created in Jamf Pro

### Verify Release Please
- [ ] Wait for "Release Please" workflow to complete
- [ ] Check if release PR was created
  - [ ] Review CHANGELOG.md updates
  - [ ] Verify version bump (should be 0.2.0)
- [ ] (Optional) Merge release PR to create GitHub release

## Post-Setup Tasks

### Documentation
- [ ] Customise README.md for your organisation
- [ ] Update CONTRIBUTING.md with team-specific guidelines
- [ ] Add team members to CODEOWNERS (optional)
- [ ] Document any custom processes

### Team Onboarding
- [ ] Share repository with team members
- [ ] Provide access to Jamf Pro (read-only for most)
- [ ] Share API client credentials securely (or create individual clients)
- [ ] Conduct training session on workflow
- [ ] Document common tasks and procedures

### Monitoring Setup
- [ ] Configure GitHub Actions notifications
  - [ ] Email notifications for failed workflows
  - [ ] Slack integration (optional)
- [ ] Set up deployment notifications
- [ ] Create dashboard for deployment status (optional)

### Backup and Recovery
- [ ] Document state backup procedures
- [ ] Set up remote state backend (S3, Terraform Cloud)
- [ ] Document rollback procedures
- [ ] Test recovery process in dev environment

## Optional Enhancements

### Advanced Configuration
- [ ] Set up Terraform Cloud for state management
- [ ] Configure multiple environments (dev/staging/prod)
- [ ] Implement approval gates for production
- [ ] Add custom validation scripts
- [ ] Set up automated testing

### Integrations
- [ ] Slack webhook for notifications
- [ ] ServiceNow integration
- [ ] Jira integration for change tickets
- [ ] Datadog/Prometheus monitoring

### Security Enhancements
- [ ] Enable Dependabot for dependency updates
- [ ] Configure CodeQL scanning
- [ ] Set up secret scanning
- [ ] Implement OPA policies for Terraform
- [ ] Add compliance checks

## Troubleshooting Checklist

If something doesn't work, verify:

- [ ] All prerequisites are installed and up-to-date
- [ ] Jamf Pro API credentials are correct
- [ ] API client has sufficient permissions
- [ ] GitHub repository secrets are configured correctly
- [ ] Branch protection rules are properly set
- [ ] `.env` file is configured locally
- [ ] Terraform is initialised
- [ ] No syntax errors in Terraform files
- [ ] Network connectivity to Jamf Pro
- [ ] GitHub Actions have proper permissions

## Success Criteria

You've successfully set up the repository when:

- ✅ Local Terraform plan works without errors
- ✅ Can connect to Jamf Pro API
- ✅ PR checks run successfully
- ✅ Terraform plan appears in PR comments
- ✅ Merge triggers automatic deployment
- ✅ Resources appear in Jamf Pro
- ✅ Release Please creates release PRs
- ✅ Team members can follow the workflow

## Next Steps

Now that your repository is set up:

1. **Learn the workflow** - Review CONTRIBUTING.md
2. **Customise for your environment** - Modify example resources
3. **Add real resources** - Start managing your Jamf Pro configuration
4. **Invite your team** - Onboard team members
5. **Iterate and improve** - Refine processes as you go

---

**Congratulations! Your Jamf Pro IaC repository is ready to use! 🎉**

For questions or issues, refer to:
- README.md for general information
- QUICKSTART.md for getting started guide
- ARCHITECTURE.md for technical details
- CONTRIBUTING.md for contribution guidelines
