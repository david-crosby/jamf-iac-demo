# Architecture and Workflow Documentation

## System Architecture

### Overview

This repository implements a GitOps-based Infrastructure as Code (IaC) solution for managing Jamf Pro using Terraform and GitHub Actions.

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Developer Workflow                          │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Local Development                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │ Clone Repo   │→ │ Create       │→ │ Make Changes │             │
│  └──────────────┘  │ Branch       │  │ to Terraform │             │
│                    └──────────────┘  └──────────────┘             │
│                                              ▼                       │
│                                    ┌──────────────────┐             │
│                                    │ Commit (semantic)│             │
│                                    └──────────────────┘             │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  GitHub - Pull Request Stage                                        │
│  ┌──────────────────────────────────────────────────────────┐      │
│  │ Automated Checks (terraform-pr.yml)                      │      │
│  │  • Terraform Format Check                                │      │
│  │  • Terraform Validate                                    │      │
│  │  • Terraform Plan (preview changes)                      │      │
│  │  • Security Scan (Trivy)                                 │      │
│  │  • Commit Message Validation                             │      │
│  └──────────────────────────────────────────────────────────┘      │
│                                    │                                │
│                                    ▼                                │
│  ┌──────────────────────────────────────────────────────────┐      │
│  │ Code Review                                              │      │
│  │  • Review Terraform plan output                          │      │
│  │  • Approve changes                                       │      │
│  └──────────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Merge to Main Branch                                               │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                     ┌──────────────┴──────────────┐
                     ▼                             ▼
┌─────────────────────────────────┐  ┌────────────────────────────────┐
│  Deployment (terraform-apply)   │  │  Release Please                │
│  • Terraform Init               │  │  • Detects semantic commits    │
│  • Terraform Plan               │  │  • Creates release PR          │
│  • Terraform Apply              │  │  • Updates CHANGELOG           │
│  • Apply to Jamf Pro            │  │  • Bumps version               │
│  • Notification                 │  │  • Creates GitHub release      │
└─────────────────────────────────┘  └────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Jamf Pro Tenant                                                     │
│  • Computer Groups                                                   │
│  • Policies                                                          │
│  • Scripts                                                           │
│  • Configuration Profiles                                            │
│  • And more...                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Local Development Environment

**Tools Required:**
- Terraform (>= 1.5.0)
- Python 3.9+ with `uv`
- Git
- Text editor/IDE

**Key Files:**
- `.env` - Local credentials (never committed)
- `terraform/` - Terraform configurations
- `scripts/setup-local.sh` - Environment setup script

### 2. GitHub Actions Workflows

#### 2.1 Pull Request Validation (`terraform-pr.yml`)

**Triggers:** Pull request to main branch with changes in `terraform/` directory

**Jobs:**
1. **terraform-check**
   - Format validation (`terraform fmt -check`)
   - Initialisation (`terraform init`)
   - Validation (`terraform validate`)
   - Plan generation (`terraform plan`)
   - Adds plan as PR comment

2. **security-scan**
   - Runs Trivy security scanner
   - Uploads results to GitHub Security tab
   - Scans for misconfigurations and vulnerabilities

3. **commit-validation**
   - Validates commit messages follow Conventional Commits
   - Uses commitizen for validation

**Environment Variables Required:**
- `JAMF_URL`
- `JAMF_CLIENT_ID`
- `JAMF_CLIENT_SECRET`

#### 2.2 Deployment (`terraform-apply.yml`)

**Triggers:** Push to main branch with changes in `terraform/` directory

**Jobs:**
1. **terraform-apply**
   - Runs in `production` environment
   - Executes `terraform apply` automatically
   - Creates deployment notification
   - Logs detailed output

2. **notify-slack** (optional)
   - Sends deployment notification to Slack
   - Requires `SLACK_WEBHOOK_URL` secret

**Protection:**
- Uses GitHub Environments for additional approval gates (optional)
- Can require manual approval before deployment

#### 2.3 Release Management (`release-please.yml`)

**Triggers:** Push to main branch

**Actions:**
- Analyses commit messages since last release
- Determines version bump (major/minor/patch)
- Creates release PR with:
  - Updated `CHANGELOG.md`
  - Version bump
  - Consolidated changes
- Creates GitHub release when release PR is merged
- Tags repository with version numbers

### 3. Terraform Configuration

#### Directory Structure

```
terraform/
├── versions.tf          # Provider requirements and configuration
├── variables.tf         # Input variable definitions
├── main.tf             # Main resource definitions
├── outputs.tf          # Output values
├── modules/            # Reusable modules
│   └── computer-groups/
│       ├── main.tf
│       └── README.md
└── environments/       # Environment-specific configs (future use)
    ├── dev/
    └── prod/
```

#### State Management

**Options:**

1. **Local State (Default)**
   - Stored locally in `terraform.tfstate`
   - Not suitable for teams
   - Good for learning/testing

2. **Remote State (Recommended)**
   - S3 + DynamoDB (AWS)
   - Terraform Cloud
   - Enables collaboration
   - State locking prevents conflicts

**Configuration Example (S3):**
```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state"
    key            = "jamf/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### 4. Security Model

#### Secrets Management

**GitHub Secrets:**
- `JAMF_URL` - Jamf Pro instance URL
- `JAMF_CLIENT_ID` - API client ID
- `JAMF_CLIENT_SECRET` - API client secret
- `SLACK_WEBHOOK_URL` - (Optional) Slack notifications

**Local Development:**
- `.env` file (gitignored)
- Never committed to repository
- Template provided as `.env.example`

#### API Permissions

**Minimum Required Permissions:**
- Read: All resources to manage
- Create: All resources to create
- Update: All resources to modify
- Delete: (Optional) If needed

**Best Practices:**
- Use separate API clients for CI/CD and local development
- Rotate credentials regularly
- Audit API client usage
- Limit permissions to only what's needed

### 5. Branching Strategy

```
main (protected)
├── feat/new-feature      # New features
├── fix/bug-fix          # Bug fixes
├── docs/update-docs     # Documentation
└── chore/maintenance    # Maintenance tasks
```

**Branch Protection Rules:**
- Require pull request reviews
- Require status checks to pass
- Enforce linear history (squash merge)
- No direct pushes to main

### 6. Release Workflow

```
Commit → PR → Merge → Release Please Analysis
                              │
                              ├─ feat commits → Minor version bump (0.1.0 → 0.2.0)
                              ├─ fix commits  → Patch version bump (0.1.0 → 0.1.1)
                              └─ BREAKING      → Major version bump (0.1.0 → 1.0.0)
                              
                              ↓
                              
                      Create Release PR
                              │
                              ├─ Update CHANGELOG.md
                              ├─ Bump version
                              └─ List all changes
                              
                              ↓
                              
                      Merge Release PR
                              │
                              ↓
                              
                      Create GitHub Release
                              │
                              ├─ Tag: v0.2.0
                              └─ Publish release notes
```

## Data Flow

### 1. Configuration Flow

```
Developer
    ↓
Terraform Files (.tf)
    ↓
Git Commit (semantic)
    ↓
GitHub PR
    ↓
Automated Validation
    ↓
Code Review
    ↓
Merge to Main
    ↓
Terraform Apply
    ↓
Jamf Pro API
    ↓
Jamf Pro Resources Updated
```

### 2. State Flow

```
Terraform State
    ↓
Terraform Plan (Compare desired vs actual)
    ↓
Changes Identified
    ↓
Terraform Apply
    ↓
Updated State
```

## Disaster Recovery

### State File Recovery

1. **State file corruption:**
   ```bash
   # Restore from backup
   terraform state pull > backup.tfstate
   ```

2. **Lost state file:**
   - Use `terraform import` to import existing resources
   - Restore from remote backend backup

3. **Drift detection:**
   ```bash
   terraform plan -detailed-exitcode
   ```

### Rollback Procedures

1. **Immediate rollback:**
   - Revert the merge commit
   - Push to main (triggers new deployment)

2. **Selective rollback:**
   - Create new PR with reverted changes
   - Follow normal PR workflow

3. **Emergency rollback:**
   - Manual intervention in Jamf Pro
   - Document changes
   - Update Terraform to match

## Monitoring and Observability

### GitHub Actions Logs

- View in Actions tab
- Download logs for debugging
- Set up notifications for failures

### Terraform Outputs

- Review in PR comments
- Check Actions run logs
- Use `terraform show` locally

### Jamf Pro Audit

- Review changes in Jamf Pro History
- Compare with Terraform state
- Validate resource configurations

## Scalability Considerations

### Multi-Environment Support

Structure for multiple environments:

```
terraform/
└── environments/
    ├── dev/
    │   ├── main.tf
    │   └── terraform.tfvars
    ├── staging/
    │   ├── main.tf
    │   └── terraform.tfvars
    └── prod/
        ├── main.tf
        └── terraform.tfvars
```

### Team Collaboration

- Use Terraform Cloud for state management
- Implement CODEOWNERS file
- Set up team-specific workflows
- Use branch protection rules

### Performance Optimisation

- Use Terraform modules for reusability
- Implement resource targeting for large changes
- Consider workspace separation
- Use parallel execution where safe

## Future Enhancements

### Potential Improvements

1. **Multi-Tenancy**
   - Support multiple Jamf Pro instances
   - Environment-specific configurations
   - Separate state per tenant

2. **Advanced Testing**
   - Terraform testing framework
   - Policy validation
   - Compliance checking

3. **Monitoring Integration**
   - Datadog/Prometheus metrics
   - Deployment dashboards
   - Alerting on failures

4. **Enhanced Automation**
   - Auto-remediation of drift
   - Scheduled compliance checks
   - Automated documentation generation

5. **Integration Options**
   - ServiceNow integration
   - Jira ticket creation
   - PagerDuty alerts
