# Contributing to Jamf Pro IaC Demo

Thank you for your interest in contributing! This document provides guidelines for contributing to this Infrastructure as Code project.

## Code of Conduct

- Be respectful and professional
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect different viewpoints and experiences

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/jamf-iac-demo.git
   cd jamf-iac-demo
   ```
3. **Set up your development environment**:
   ```bash
   chmod +x scripts/setup-local.sh
   ./scripts/setup-local.sh
   ```
4. **Configure your Jamf Pro credentials** in the `.env` file

## Development Workflow

### 1. Create a Branch

Always create a new branch for your changes. Use the semantic commit convention for branch names:

```bash
# Feature branch
git checkout -b feat/add-new-policy

# Bug fix branch
git checkout -b fix/policy-scope-issue

# Documentation
git checkout -b docs/update-readme
```

### 2. Make Your Changes

- Follow Terraform best practices
- Keep changes focused and atomic
- Test locally before pushing
- Add comments for complex logic

### 3. Test Locally

Before committing, test your changes:

```bash
cd terraform

# Format your code
terraform fmt -recursive

# Validate configuration
terraform validate

# Review planned changes
terraform plan
```

### 4. Commit Your Changes

Use semantic commit messages following the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```bash
# Using commitizen (recommended)
cz commit

# Or manually
git add .
git commit -m "feat(policies): add software update policy

Add a new policy to enforce software updates on macOS devices.
Targets devices running macOS Sonoma or later."
```

#### Commit Message Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, semicolons, etc.)
- `refactor`: Code refactoring without functionality change
- `test`: Adding or updating tests
- `chore`: Maintenance tasks, dependency updates
- `ci`: CI/CD changes

**Scopes:**
- `groups`: Computer groups
- `policies`: Policies
- `scripts`: Scripts
- `profiles`: Configuration profiles
- `workflows`: GitHub Actions workflows
- `docs`: Documentation
- `core`: Core Terraform configuration

**Breaking Changes:**
Add `!` after type or include `BREAKING CHANGE:` in footer:
```
feat(policies)!: change policy naming convention

BREAKING CHANGE: Policy names now use kebab-case instead of spaces
```

### 5. Push and Create Pull Request

```bash
# Push your branch
git push origin feat/add-new-policy

# Create PR (using GitHub CLI)
gh pr create --title "feat(policies): add software update policy" \
             --body "Adds automatic software update policy for macOS devices"

# Or create PR via GitHub web interface
```

## Pull Request Guidelines

### PR Checklist

Before submitting a PR, ensure:

- [ ] Code follows Terraform style guidelines (`terraform fmt`)
- [ ] All Terraform configurations are valid (`terraform validate`)
- [ ] Changes have been tested locally
- [ ] Commit messages follow semantic conventions
- [ ] PR title follows semantic format
- [ ] PR description clearly explains the changes
- [ ] No sensitive information (credentials, secrets) included
- [ ] Documentation updated if needed

### PR Description Template

```markdown
## Description
Brief description of what this PR does.

## Type of Change
- [ ] New feature (feat)
- [ ] Bug fix (fix)
- [ ] Documentation update (docs)
- [ ] Code refactoring (refactor)
- [ ] CI/CD changes (ci)

## Changes Made
- Detailed list of changes
- Resource additions/modifications
- Configuration updates

## Testing
How was this tested?
- [ ] Local terraform plan
- [ ] Applied to test environment
- [ ] Verified in Jamf Pro UI

## Screenshots (if applicable)
Add screenshots showing the changes in Jamf Pro.

## Related Issues
Closes #issue_number
```

### Review Process

1. **Automated Checks**: PR must pass all automated checks
   - Terraform format validation
   - Terraform plan succeeds
   - No security issues detected
   - Commit messages validated

2. **Code Review**: At least one approval required
   - Reviewer examines Terraform plan output
   - Checks for security implications
   - Validates best practices

3. **Testing**: Changes tested in non-production environment

4. **Merge**: Use "Squash and merge" to keep history clean

## Terraform Best Practices

### Resource Naming

- Use lowercase with underscores: `jamf_computer_group.mac_fleet`
- Be descriptive: `macos_sonoma` not `group1`
- Include environment where appropriate: `prod_web_servers`

### Variable Definitions

- Always provide descriptions
- Use appropriate types
- Set sensible defaults where possible
- Mark sensitive variables as sensitive

### Module Structure

- Keep modules focused and reusable
- Document inputs and outputs
- Include examples in module README
- Version your modules

### State Management

- Never commit state files
- Use remote backend for collaboration
- Enable state locking
- Backup state regularly

## Documentation

When adding new features or resources:

1. **Update README.md** if adding new capabilities
2. **Add inline comments** for complex Terraform logic
3. **Document variables** with clear descriptions
4. **Update examples** if changing usage patterns

## Security Considerations

### Credentials and Secrets

- **NEVER** commit credentials or secrets
- Use GitHub Secrets for CI/CD
- Use `.env` for local development (gitignored)
- Rotate credentials regularly

### Access Control

- Request minimum required Jamf API permissions
- Document permission requirements
- Use separate credentials for CI/CD

### Code Review

- Review all Terraform plans before applying
- Check for unintended resource deletions
- Validate scope changes carefully
- Watch for privilege escalation

## Troubleshooting

### Terraform Format Fails

```bash
# Auto-fix formatting issues
terraform fmt -recursive
```

### Terraform Plan Fails Locally

```bash
# Check your .env file is sourced
source .env

# Verify credentials
echo $JAMF_URL

# Re-initialise Terraform
cd terraform
rm -rf .terraform
terraform init
```

### Semantic Commit Validation Fails

```bash
# Use commitizen to help with message format
cz commit

# Or reference the conventional commits guide
open https://www.conventionalcommits.org/
```

### PR Checks Failing

1. Check the Actions tab for detailed error logs
2. Run the same checks locally
3. Fix issues and push updated commits

## Getting Help

- **Issues**: Open a GitHub issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check the README and Terraform provider docs
- **Examples**: Review existing resources in `terraform/main.tf`

## Recognition

Contributors will be:
- Listed in release notes (via Release Please)
- Credited in the CHANGELOG
- Recognised in the repository

Thank you for contributing to making Jamf Pro management better through Infrastructure as Code! 🎉
