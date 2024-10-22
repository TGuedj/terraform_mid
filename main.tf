############################################
##########          VPC
############################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.1.0.0/16"  # Update to match the VPC CIDR block

  azs                = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]  # Updated private subnets
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]  # Updated public subnets
  enable_nat_gateway = true
  create_igw         = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

############################################
##########          EC2
############################################
resource "aws_security_group" "allow_all_tcp_http_ssh" {
  name        = "allow_all_tcp_http_ssh"
  description = "Allow all TCP, HTTP, and SSH traffic"
  vpc_id      = module.vpc.vpc_id

  # Allow all TCP traffic
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from all IP addresses (consider restricting for security)
  }

  # Allow HTTP access (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from all IP addresses
  }

  # Allow all outbound traffic (egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_tcp_http_ssh"
  }
}




module "web_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  depends_on = [ module.vpc ]
  for_each = var.instances

  name                   = each.key
  instance_type          = "t2.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_all_tcp_http_ssh.id] 

  # Use the output from the VPC module directly for private subnets
  subnet_id = element(module.vpc.private_subnets, index(keys(var.instances), each.key))


  user_data = each.value.user_data

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = each.key
  }
}




# output "alb_dns" {
#   value = aws_lb.alb.dns_name
#   description = "ALB DNS Name"
# }

# output "first_instance_private_ip" {
#   value = aws_instance.app_instance_1.private_ip
#   description = "Private IP of the first application instance"
# }

# output "second_instance_private_ip" {
#   value = aws_instance.app_instance_2.private_ip
#   description = "Private IP of the second application instance"
# }



# module "web_instance_public" {
#   source = "terraform-aws-modules/ec2-instance/aws"

 
#   instance_type          = "t2.micro"
#   key_name               = "vockey"  # Update with your key name
#   monitoring             = true
#   vpc_security_group_ids = [aws_security_group.web_sg.id]

#   # Use the output from the VPC module directly for public subnets
#   subnet_id =module.vpc.public_subnets[0]


# }

# # Security Group for SSH, HTTP, and ICMP access
# resource "aws_security_group" "web_sg" {
#   vpc_id = module.vpc.vpc_id

#   name        = "web_sg"
#   description = "Allow SSH, HTTP, and ICMP traffic"

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere, change to restrict access
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # HTTP access from anywhere
#   }

#   ingress {
#     from_port   = -1
#     to_port     = -1
#     protocol    = "icmp"
#     cidr_blocks = ["0.0.0.0/0"]  # Allow all ICMP traffic (e.g., ping)
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"  # Allow all outbound traffic
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "web-sg"
#     Environment = "dev"
#   }
# }
