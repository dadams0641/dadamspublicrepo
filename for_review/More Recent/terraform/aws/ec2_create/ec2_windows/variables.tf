##### Adjust These Variables #####

variable "sg_name" {
  default = "Freedom" 
}

variable "vpc_name" {
  default = "dev-vpc"
}

variable "subnet_id" {
  default = "subnet-0d4ed851a151f9a57"
}

variable "instance_type" {
  default = "c5.xlarge"
}

variable "instance_name" {
  default = "am-dsaspcf-s19"
}

variable "number_of_instances" {
  default = "1"
}

variable "volume_type" {
  default = "gp2"
}

variable "volume_size" {
  default = "100"
}

variable "iops" {
  default = "1500"
}

variable "tags" {
  type = map(string)
  default = {
    AppName		   	= "SAS PC FILE Server"
    AppOwner			= "Chuck Lewis"
    Automation  = "Terraform"
    Backup			= "{\"Snapshot\":{\"time\":{\"interval\":24},\"retention\":10,\"volumes\":[\"all\"]}}"
    BusinessUnit		= "Information Technology"
    CostCenter   		= "IT Information Technology"
    CostAllocation		= "00444"
    Description		= "Automated Deployment of SAS PC File EC2 Instance"
    Environment	  	= "Dev"
    InstanceManager		= "Windows"
    Name			= "am-dsaspcf-s19"
    Product		  	= "SAS"
  }
}

##### Do Not Modify These Variables #####

variable "secret_name"{
  default = "aws-adj"
}
variable "eagle_secret_name" {
  default = "/privami/eaglepass"
}
variable "volume_encryption" {
  default = "true"
}
variable "domain_join" {
  type = bool
  default = false
}
variable "instance_profile" {
  type = string
  default = "ec2-windows-standard-role"
}