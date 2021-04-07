terraform {
  backend "s3" {
    bucket  			= "terraform-state-fhmc-np"
    region      		= "us-east-1"
  }
}