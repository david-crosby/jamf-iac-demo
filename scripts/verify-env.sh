#!/bin/bash

# Environment Variable Verification Script
# Checks that all required environment variables are properly set for Terraform

set -e

# Colour codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Colour

echo "🔍 Verifying Terraform Environment Variables"
echo ""

# Function to check if a variable is set and not empty
check_var() {
    local var_name=$1
    local var_value="${!var_name}"
    
    if [ -z "$var_value" ]; then
        echo -e "${RED}✗ $var_name is NOT set${NC}"
        return 1
    else
        # Mask sensitive values
        if [[ "$var_name" == *"SECRET"* ]] || [[ "$var_name" == *"CLIENT_ID"* ]]; then
            local masked_value="${var_value:0:10}..."
            echo -e "${GREEN}✓ $var_name is set${NC} (${masked_value})"
        else
            echo -e "${GREEN}✓ $var_name is set${NC} (${var_value})"
        fi
        return 0
    fi
}

echo "Checking Jamf Pro credentials:"
all_set=true

if ! check_var "JAMF_INSTANCE_FQDN"; then
    all_set=false
fi

if ! check_var "JAMF_AUTH_METHOD"; then
    all_set=false
fi

if ! check_var "JAMF_CLIENT_ID"; then
    all_set=false
fi

if ! check_var "JAMF_CLIENT_SECRET"; then
    all_set=false
fi

echo ""
echo "Checking Terraform variables:"

if ! check_var "TF_VAR_jamf_instance_fqdn"; then
    all_set=false
fi

if ! check_var "TF_VAR_jamf_auth_method"; then
    all_set=false
fi

if ! check_var "TF_VAR_jamf_client_id"; then
    all_set=false
fi

if ! check_var "TF_VAR_jamf_client_secret"; then
    all_set=false
fi

if ! check_var "TF_VAR_environment"; then
    all_set=false
fi

echo ""

if [ "$all_set" = true ]; then
    echo -e "${GREEN}✅ All required environment variables are set!${NC}"
    echo ""
    echo "You can now run Terraform commands:"
    echo "  cd terraform"
    echo "  terraform init"
    echo "  terraform plan"
    exit 0
else
    echo -e "${RED}❌ Some environment variables are missing!${NC}"
    echo ""
    echo "To fix this:"
    echo "1. Ensure .env file exists and contains your credentials"
    echo "2. Load the variables: source .env"
    echo "3. Run this script again: ./scripts/verify-env.sh"
    echo ""
    echo "Example .env file content:"
    echo '  export JAMF_INSTANCE_FQDN="yourinstance.jamfcloud.com"'
    echo '  export JAMF_AUTH_METHOD="oauth2"'
    echo '  export JAMF_CLIENT_ID="your-client-id"'
    echo '  export JAMF_CLIENT_SECRET="your-client-secret"'
    echo '  export TF_VAR_jamf_instance_fqdn="$JAMF_INSTANCE_FQDN"'
    echo '  export TF_VAR_jamf_auth_method="$JAMF_AUTH_METHOD"'
    echo '  export TF_VAR_jamf_client_id="$JAMF_CLIENT_ID"'
    echo '  export TF_VAR_jamf_client_secret="$JAMF_CLIENT_SECRET"'
    echo '  export TF_VAR_environment="dev"'
    exit 1
fi
