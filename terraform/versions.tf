terraform {
  required_version = ">= 1.5.0"

  required_providers {
    jamfpro = {
      source  = "deploymenttheory/jamfpro"
      version = "~> 0.20.0"
    }
  }

  # Optional: Configure remote backend for state management
  # Uncomment and configure for team collaboration
  
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "jamf/terraform.tfstate"
  #   region         = "eu-west-2"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }

  # OR use Terraform Cloud
  # backend "remote" {
  #   organization = "your-org"
  #   workspaces {
  #     name = "jamf-pro"
  #   }
  # }
}

provider "jamfpro" {
  jamfpro_instance_fqdn            = var.jamf_instance_fqdn
  auth_method                       = var.jamf_auth_method
  client_id                         = var.jamf_client_id
  client_secret                     = var.jamf_client_secret
  jamfpro_load_balancer_lock        = true
  mandatory_request_delay_milliseconds = 100
}
