terraform {
  backend "s3" {
    bucket  			= "fm-terraform-test"
    region      		= "us-east-1"
    shared_credentials_file	= "$HOME/.aws/credentials"
    profile			= "pocaws"
  }
}

