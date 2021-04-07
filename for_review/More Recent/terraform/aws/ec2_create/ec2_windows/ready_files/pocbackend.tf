terraform {
  backend "s3" {
    bucket  			= "fhmc-cloudengineering"
    region      		= "us-east-1"
    #shared_credentials_file	= "$HOME/.aws/credentials"
    #profile = "dev"
  }
}
