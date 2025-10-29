#!/bin/bash

# Local Development Setup Script for Jamf IaC Demo
# This script helps set up your local environment for Terraform development

set -e

echo "🚀 Setting up Jamf IaC local development environment..."
echo ""

# Colour codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Colour

# Function to print coloured messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_warning "This script is optimised for macOS. Some checks may not apply."
fi

# Check for required tools
echo "Checking for required tools..."

# Check Terraform
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version -json | python3 -c "import sys, json; print(json.load(sys.stdin)['terraform_version'])")
    print_success "Terraform ${TERRAFORM_VERSION} found"
else
    print_error "Terraform not found. Please install from https://www.terraform.io/downloads"
    echo "  For macOS: brew install terraform"
    exit 1
fi

# Check Python (for commitizen)
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    print_success "Python ${PYTHON_VERSION} found"
else
    print_error "Python 3 not found. Please install Python 3.9+"
    exit 1
fi

# Check for uv (preferred) or pip
if command -v uv &> /dev/null; then
    print_success "uv package manager found (preferred)"
    PACKAGE_MANAGER="uv"
elif command -v pip3 &> /dev/null; then
    print_warning "pip3 found. Consider installing uv for faster package management"
    echo "  Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
    PACKAGE_MANAGER="pip3"
else
    print_error "Neither uv nor pip3 found. Please install a Python package manager"
    exit 1
fi

# Check Git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    print_success "Git ${GIT_VERSION} found"
else
    print_error "Git not found. Please install Git"
    exit 1
fi

echo ""
echo "Installing Python development tools..."

# Install commitizen for semantic commits
if [ "$PACKAGE_MANAGER" = "uv" ]; then
    uv pip install commitizen --system 2>/dev/null || uv pip install commitizen
else
    pip3 install commitizen --break-system-packages 2>/dev/null || pip3 install commitizen
fi
print_success "commitizen installed"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo ""
    echo "Creating .env file template..."
    cat > .env << 'EOF'
# Jamf Pro Configuration
# IMPORTANT: Never commit this file to Git!
#
# Usage: source .env (or . .env)

# Your Jamf Pro instance FQDN (WITHOUT https://)
# Example: yourinstance.jamfcloud.com (NOT https://yourinstance.jamfcloud.com)
export JAMF_INSTANCE_FQDN=""

# Authentication method: oauth2 (recommended) or basic
export JAMF_AUTH_METHOD="oauth2"

# API Client Credentials (for OAuth2 authentication)
# Create these in Jamf Pro: Settings > System > API Roles and Clients
export JAMF_CLIENT_ID=""
export JAMF_CLIENT_SECRET=""

# Terraform Variables (TF_VAR_ prefix makes them available to Terraform)
export TF_VAR_jamf_instance_fqdn="$JAMF_INSTANCE_FQDN"
export TF_VAR_jamf_auth_method="$JAMF_AUTH_METHOD"
export TF_VAR_jamf_client_id="$JAMF_CLIENT_ID"
export TF_VAR_jamf_client_secret="$JAMF_CLIENT_SECRET"
export TF_VAR_environment="dev"

# Optional: Terraform Cloud/Enterprise
# export TF_CLOUD_ORGANIZATION="your-org"
# export TF_WORKSPACE="jamf-pro"

# Optional: Slack notifications (for CI/CD)
# export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
EOF
    print_success ".env file created"
    print_warning "Please edit .env and add your Jamf Pro credentials"
    echo ""
    echo "After editing .env, load it with: source .env"
else
    print_warning ".env file already exists, skipping creation"
fi

# Create .envrc for direnv users (optional)
if command -v direnv &> /dev/null; then
    if [ ! -f .envrc ]; then
        echo 'dotenv' > .envrc
        direnv allow
        print_success ".envrc created for direnv"
    fi
fi

# Add .env to .gitignore if not already there
if [ -f .gitignore ]; then
    if ! grep -q "^\.env$" .gitignore; then
        echo ".env" >> .gitignore
        print_success "Added .env to .gitignore"
    fi
else
    echo ".env" > .gitignore
    print_success "Created .gitignore with .env"
fi

# Initialise Terraform
echo ""
echo "Would you like to initialise Terraform now? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    if [ -f .env ]; then
        source .env
    fi
    cd terraform
    terraform init
    print_success "Terraform initialised"
    cd ..
fi

echo ""
print_success "Setup complete! 🎉"
echo ""
echo "Next steps:"
echo "1. Edit .env with your Jamf Pro credentials:"
echo "   nano .env  # or use your preferred editor"
echo ""
echo "   IMPORTANT: Enter your Jamf FQDN WITHOUT https://"
echo "   Example: yourinstance.jamfcloud.com"
echo "   NOT: https://yourinstance.jamfcloud.com"
echo ""
echo "2. Load the environment variables:"
echo "   source .env"
echo ""
echo "3. Verify variables are loaded:"
echo "   echo \$TF_VAR_jamf_instance_fqdn"
echo ""
echo "4. Test Terraform: cd terraform && terraform plan"
echo "5. Create a feature branch: git checkout -b feat/your-feature"
echo "6. Make changes and commit using semantic commits"
echo "7. Push and create a PR"
echo ""
echo "For semantic commit help, run: cz commit"
echo ""
echo "💡 Tip: To automatically load .env when entering this directory,"
echo "   install direnv and run: echo 'dotenv' > .envrc && direnv allow"
echo ""
