provider "aws" {
  region			= "us-east-1"
  #shared_credentials_file	= "$HOME/.aws/credentials"
  #profile = "dev"
}


locals {
  resource_tags = {
    "AppName"		  	= var.tags["AppName"]
    "AppOwner"			= var.tags["AppOwner"]
    "Backup"			= var.tags["Backup"]
    "BusinessUnit"		= var.tags["BusinessUnit"]
    "CostCenter"    		= var.tags["CostCenter"]
    "CostAllocation"		= var.tags["CostAllocation"]
    "Description"		= var.tags["Description"]
    "Environment"	  	= var.tags["Environment"]
    "InstanceManager"		= var.tags["InstanceManager"]
    "Product"		  	= var.tags["Product"]
  }
}

data "aws_secretsmanager_secret" "secret" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = data.aws_secretsmanager_secret.secret.id
}

data "aws_ssm_parameter" "ami" {
  name = "/ci/Private_Windows_AMI_ID"
}

data "aws_secretsmanager_secret" "eagle_secret" {
  name = var.eagle_secret_name
}

data "aws_secretsmanager_secret_version" "eagle_secret_version" {
  secret_id     = data.aws_secretsmanager_secret.eagle_secret.id
}

data "aws_security_group" "security_group" {
  name = var.sg_name
}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = [var.vpc_name]
  }
}


module "ec2_instance" {
  instance_count          = var.number_of_instances
  source                  = "./modules/<<env>>/ec2_windows_create"
  eaglepass               = data.aws_secretsmanager_secret_version.eagle_secret_version.secret_string
  name_tag                = "${var.instance_name}"
  ami_id                  = data.aws_ssm_parameter.ami.value
  ec2_type                = var.instance_type
  monitoring              = true
  public_ip               = false
  security_group_ids      = [data.aws_security_group.security_group.id]
  subnet_id               = var.subnet_id
  password                = data.aws_secretsmanager_secret_version.secret_version.secret_string
  resource_tags           = local.resource_tags
  termination_protection  = true
  ebs_term_delete         = true
  ebs_type                = var.volume_type
  ebs_size                = var.volume_size
  ebs_encryption          = var.volume_encryption
  domain_join             = var.domain_join
  iam_profile             = var.instance_profile 

}