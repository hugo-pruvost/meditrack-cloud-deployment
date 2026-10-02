provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Identite du compte AWS courant (utilisee pour rendre le nom du bucket unique)
data "aws_caller_identity" "current" {}
