variable "sg_name" {
  default = "Freedom" 
}

variable "vpc_name" {
  default = "dev-vpc"
}

variable "subnet_id" {
  default = "subnet-0a1020d62b0136a84"
}

variable "instance_type" {
  default = "c5.xlarge"
}

variable "secret_name"{
  default = "aws-adj"
}

variable "instance_name" {
  default = "in-sripenm-s19"
}

variable "number_of_instances" {
  default = "2"
}

variable "volume_type" {
  default = "gp2"
}

/*variable "iops" {
  default = "1500"
}*/

variable "volume_size" {
  default = "150"
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

variable "tags" {
  type = map(string)
  default = {
    AppName		   	  = "Linux-EC2"
    AppOwner			  = "Srikanth Penmetsa"
    Backup			    = "Not Yet Assigned"
    BusinessUnit		= "Information Technology"
    CostCenter   		= "NoneAssigned"
    CostAllocation	= "Technology and Infrastructure"
    Description		  = "Automate Linux EC2 Instances Testing"
    Environment	  	= "dev"
    InstanceManager	= "Linux"
    Name			      = "in-sripenm-s19"
    Product		  	  = "Linux EC2 Instance"
  }
}