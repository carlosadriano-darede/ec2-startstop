terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#---------------------------
# Configure the AWS Provider
#---------------------------
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "bkt003042025"
    key    = "terraform/ec2-startstop"
    region = "us-east-1"
  }
}