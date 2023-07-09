# Define provider and region
provider "aws" {
  region = "us-east-1"
}

# Define provider and terraform versions
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
