provider "aws" {
  region			= "us-east-1"
  version 			= "~>3.0"
  shared_credentials_file	= "$HOME/.aws/credentials"
 profile			= "pocaws"
  
}

variable "json" {
  type = any
  description = "Allows the use of the Terraform TFVars JSON document."
}

locals {
  resource_tags = {
    "AppName"		  	= var.json.tags.AppName
    "AppOwner"			= var.json.tags.AppOwner
    "Backup"			= var.json.tags.Backup
    "BusinessUnit"		= var.json.tags.BU
    "CostCenter"    		= var.json.tags.CostCenterCode
    "CostAllocation"		= var.json.tags.CostAllocation
    "Description"		= var.json.tags.Description
    "Environment"	  	= var.json.tags.Environment
    "InstanceManager"		= var.json.tags.InstanceManager
    "Name"			= var.json.tags.Name
    "Product"		  	= var.json.tags.Product
  }
}

data "aws_secretsmanager_secret" "secret" {
  name = var.json.shared_settings.secret_name
}

data "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = data.aws_secretsmanager_secret.secret.id
}

data "aws_ami" "ami" {
  most_recent = true
  name_regex       	  	= "^Windows_Server-2019*"
  owners           	  	= ["amazon"]

  filter {
    name   		  	= "platform"
    values 		  	= ["windows"]
  }

  filter {
    name			= "description"
    values			= ["Microsoft Windows Server 2019 with Desktop Experience Locale English AMI provided by Amazon"]
  }
}

data "aws_security_group" "security_group" {
  name = var.json.shared_settings.sg_name
}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = [var.json.shared_settings.vpc_name]
  }
}

data "aws_subnet_ids" "subnet_id" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name = "tag:Name"
    values = [var.json.shared_settings.subnet_name]
  }
}
  
  

resource "aws_instance" "ec2_instance" {
  ami           	  	= data.aws_ami.ami.id
  instance_type 	  	= var.json.instance_settings.instance_type
  monitoring 		  	= true
  associate_public_ip_address	= true
  vpc_security_group_ids  	= [data.aws_security_group.security_group.id]
  iam_instance_profile 	  	= var.json.shared_settings.iam_role
  disable_api_termination 	= false
  get_password_data		= false
  subnet_id 		  	= data.aws_subnet_ids.subnet_id.id
  tags 			  	= local.resource_tags
  user_data			= <<EOF
<powershell>
$pattern = "^(?![0-9]{1,15}$)[a-zA-Z0-9-]{1,15}$"
$nameValue = ${var.json.tags.Name}
If ($nameValue -match $pattern) 
{Try
        {Rename-Computer -NewName $nameValue -Restart -ErrorAction Stop} 
    Catch
        {$ErrorMessage = $_.Exception.Message
        Write-Output "Rename failed: $ErrorMessage"}}
Else
    {Throw "Provided name not a valid hostname. Please ensure Name value is between 1 and 15 characters in length and contains only alphanumeric or hyphen characters"}
$domain = "fmch.local"
$password = "${data.aws_secretsmanager_secret_version.secret_version.secret_string} | ConvertTo-SecureString -asPlainText -Force"
$username = "$domain\srv_server_automate"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName fhmc.local -Credential $credential -Restart 
</powershell>
<persist>true</persist>
EOF

  root_block_device  {
    delete_on_termination = false
    volume_type = var.json.instance_settings.volume_type
    volume_size = var.json.instance_settings.volume_size
    iops = var.json.instance_settings.iops
    encrypted = var.json.instance_settings.encryption
    
  }

}
/*
resource "aws_ssm_parameter" "secret" {
  name  = var.json.tags.Name
  type  = "SecureString"
  value = aws_instance.ec2_instance.password_data
}
*/
