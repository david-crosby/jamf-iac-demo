variable "jamf_instance_fqdn" {
  description = "The FQDN of your Jamf Pro instance (e.g., yourinstance.jamfcloud.com)"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.jamf_instance_fqdn))
    error_message = "Jamf instance FQDN must be a valid domain name (without https://)"
  }
}

variable "jamf_auth_method" {
  description = "Authentication method: 'oauth2' (recommended) or 'basic'"
  type        = string
  default     = "oauth2"

  validation {
    condition     = contains(["oauth2", "basic"], var.jamf_auth_method)
    error_message = "Authentication method must be either 'oauth2' or 'basic'"
  }
}

variable "jamf_client_id" {
  description = "Jamf Pro API client ID (for OAuth2 authentication)"
  type        = string
  sensitive   = true
}

variable "jamf_client_secret" {
  description = "Jamf Pro API client secret (for OAuth2 authentication)"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    managed_by = "terraform"
    repository = "jamf-iac-demo"
  }
}
