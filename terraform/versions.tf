terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # Provider officiel AWS (VPC, S3, CloudFront, EC2)
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80, < 7.0"
    }
  }

}
