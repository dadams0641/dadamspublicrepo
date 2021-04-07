resource "aws_instance" "ec2_instance" {
  count                       = var.instance_count
  ami           	          	= var.ami_id
  instance_type 	  	        = var.ec2_type
  associate_public_ip_address	= var.public_ip
  vpc_security_group_ids  	  = var.security_group_ids
  #iam_instance_profile 	  	= var.iam_profile
  disable_api_termination 	  = var.termination_protection
  get_password_data		        = false
  subnet_id 		             	= var.subnet_id
  tags 			                	= merge(var.resource_tags,
                   map("Name", "${var.name_tag}${count.index + 1}")) 
  monitoring                  = true 
  #tenancy                    = default

  root_block_device  {
    delete_on_termination = var.ebs_term_delete
    volume_type           = var.ebs_type
    volume_size           = var.ebs_size
    encrypted             = var.ebs_encryption
  }
}

resource "local_file" "AnsibleInventory" {
 content = templatefile("${path.module}/inventory.tmpl",
 {
  private-ip = aws_instance.ec2_instance.*.private_ip
 }
 )
 filename = "${path.module}/inventory"
}