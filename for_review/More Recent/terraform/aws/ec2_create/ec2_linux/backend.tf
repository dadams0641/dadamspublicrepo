terraform {
  backend "s3" {
    bucket  			= "terraform-state-fhmc-np"
    region      		= "us-east-1"
    shared_credentials_file	= "$HOME/.aws/credentials" 
    profile = "dev"
  }
}