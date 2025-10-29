#!/usr/bin/env python3
"""
Jamf Pro API Connection Tester
Tests connectivity and authentication to Jamf Pro API

Usage:
    python3 scripts/test-jamf-connection.py
    
Or with uv:
    uv run scripts/test-jamf-connection.py
"""

import os
import sys
import json
import urllib.request
import urllib.error
from urllib.parse import urljoin


def load_env_file(env_path=".env"):
    """Load environment variables from .env file"""
    if not os.path.exists(env_path):
        print(f"❌ Error: {env_path} file not found")
        print("Run ./scripts/setup-local.sh to create it")
        return False
    
    with open(env_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                key, value = line.split('=', 1)
                # Handle variable expansion like ${JAMF_URL}
                if value.startswith('${') and value.endswith('}'):
                    var_name = value[2:-1]
                    value = os.environ.get(var_name, '')
                if value:
                    os.environ[key] = value
    return True


def get_oauth_token(jamf_url, client_id, client_secret):
    """Obtain OAuth token from Jamf Pro"""
    token_url = urljoin(jamf_url, "/api/oauth/token")
    
    data = f"client_id={client_id}&client_secret={client_secret}&grant_type=client_credentials"
    headers = {
        'Content-Type': 'application/x-www-form-urlencoded'
    }
    
    req = urllib.request.Request(
        token_url,
        data=data.encode('utf-8'),
        headers=headers,
        method='POST'
    )
    
    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode('utf-8'))
            return result.get('access_token')
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        raise Exception(f"HTTP {e.code}: {error_body}")


def test_api_access(jamf_url, token):
    """Test API access by fetching Jamf Pro version"""
    version_url = urljoin(jamf_url, "/api/v1/jamf-pro-version")
    
    headers = {
        'Authorization': f'Bearer {token}',
        'Accept': 'application/json'
    }
    
    req = urllib.request.Request(version_url, headers=headers, method='GET')
    
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode('utf-8'))


def main():
    print("🔍 Jamf Pro API Connection Tester\n")
    
    # Load environment variables
    if not load_env_file():
        sys.exit(1)
    
    # Get configuration
    jamf_fqdn = os.environ.get('JAMF_INSTANCE_FQDN', '').strip()
    client_id = os.environ.get('JAMF_CLIENT_ID', '')
    client_secret = os.environ.get('JAMF_CLIENT_SECRET', '')
    
    # Construct full URL from FQDN
    if jamf_fqdn:
        if jamf_fqdn.startswith('http://') or jamf_fqdn.startswith('https://'):
            print("⚠️  Warning: JAMF_INSTANCE_FQDN should not include https://")
            print("   Removing protocol from FQDN...")
            jamf_fqdn = jamf_fqdn.replace('https://', '').replace('http://', '')
        jamf_url = f"https://{jamf_fqdn}".rstrip('/')
    else:
        jamf_url = ''
    
    if not all([jamf_fqdn, client_id, client_secret]):
        print("❌ Error: Missing required environment variables")
        print("Required: JAMF_INSTANCE_FQDN, JAMF_CLIENT_ID, JAMF_CLIENT_SECRET")
        print("\nPlease configure your .env file")
        sys.exit(1)
    
    print(f"📡 Testing connection to: {jamf_url}\n")
    
    # Test 1: OAuth Token
    print("1️⃣  Requesting OAuth token...")
    try:
        token = get_oauth_token(jamf_url, client_id, client_secret)
        if token:
            print(f"   ✅ Successfully obtained token (first 20 chars): {token[:20]}...")
        else:
            print("   ❌ Failed to obtain token")
            sys.exit(1)
    except Exception as e:
        print(f"   ❌ Error obtaining token: {e}")
        sys.exit(1)
    
    # Test 2: API Access
    print("\n2️⃣  Testing API access...")
    try:
        version_info = test_api_access(jamf_url, token)
        print(f"   ✅ API access successful!")
        print(f"   📦 Jamf Pro Version: {version_info.get('version', 'Unknown')}")
    except Exception as e:
        print(f"   ❌ Error accessing API: {e}")
        sys.exit(1)
    
    # Test 3: List some resources (optional)
    print("\n3️⃣  Testing resource access...")
    try:
        # Try to fetch computer groups
        groups_url = urljoin(jamf_url, "/api/v1/computer-groups")
        headers = {
            'Authorization': f'Bearer {token}',
            'Accept': 'application/json'
        }
        req = urllib.request.Request(groups_url, headers=headers, method='GET')
        
        with urllib.request.urlopen(req) as response:
            groups = json.loads(response.read().decode('utf-8'))
            total_groups = groups.get('totalCount', 0)
            print(f"   ✅ Can access computer groups")
            print(f"   📊 Found {total_groups} computer group(s)")
    except Exception as e:
        print(f"   ⚠️  Limited resource access: {e}")
        print("   This is OK - the API client may have restricted permissions")
    
    print("\n" + "="*60)
    print("✅ All tests passed! Your Jamf Pro connection is working.")
    print("="*60)
    print("\n💡 Next steps:")
    print("   1. Run: cd terraform && terraform init")
    print("   2. Run: terraform plan")
    print("   3. Review the plan output")
    print("   4. Run: terraform apply (if you want to create resources)")
    

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Test interrupted by user")
        sys.exit(0)
