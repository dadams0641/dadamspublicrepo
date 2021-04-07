variable "name_tag" {
    type        = string
    description = "The Host Name tag"
}
variable "instance_count" {
    type = number
}
variable "ami_id" {
    type	= string
    description = "The AMI ID to use for the EC2 Instance"
}
variable "ec2_type" {
    type	= string
    description = "The Type of EC2 Instance"
}
variable "monitoring" {
    type        = bool
    description = "Whether Monitoring is Enabled for the Instance. True or False."
    
}
variable "public_ip" {
    type        = bool
    description = "Whether Public IP Address is Enabled. True or False"
    
}
variable "security_group_ids" {
    type        = list(string)
    description = "The Populated Security Group IDs"
}
/* variable "instance_profile" {
    type        = string
    description = "The IAM Profile used with the EC2 Instance"
} */
variable "subnet_id" {
    type        = string
    description = "The Populated Subnet ID "
}
variable "password" {
    type        = string
    description = "The Encrypted Password for Adding Machines to the Domain"
}
variable "resource_tags" {
    type        = map(string)
    description = "Map of the Resource Tags"
}
variable "termination_protection" {
    type        = bool
    description = "Whether or Not Termination Protection is Enabled. True or False"
    
}
variable "ebs_term_delete" {
    type        = bool
    description = "Whether or Not The EBS Volume Will Delete Upon EC2 Termination. True or False"
}
variable "ebs_type" {
    type        = string
    description = "EBS Volume Type"
}
variable "ebs_size" {
    type	    = number
    description = "Size of the EBS Volume in GiB"
}
/*variable "ebs_iops" {
    type	    = number
    description = "IOPS to be assigned to IO1 or IO2 Instances. Comment out if GP2 or GP3"
}*/
variable "ebs_encryption" {
    type	    = bool
    description = "Whether EBS Encryption is Enabled. True or False"
    default     = true
}

variable "domain_join" {
  type    = bool
}

variable "iam_profile" {
  type = string
} 
