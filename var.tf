variable "AWS_REGION" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "The AWS vpc name"
  type        = string
  default     = "sample"

}

variable "vpc_cidr" {
  description = "The AWS vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"

}


variable "instance_names" {
  type    = list(string)
  default = ["instance-private-1", "instance-private-2", "instance-private-3", "instance-private-4"]
}




resource "aws_security_group" "instance_sg" {
  name        = "instance_security_group"
  description = "Allow inbound traffic from ALB"
  vpc_id      = module.vpc.vpc_id

  # Allow HTTP traffic from ALB's security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Reference ALB SG
    description     = "Allow HTTP from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance_sg"
  }
}

# Attach the security group to the instances





variable "instances" {
  type = map(object({
    user_data = string
  }))
  default = {
    "instance-private-1" = {
      user_data = <<-EOF
      #!/bin/bash

      # Update the system packages
      yum update -y

      # Install Docker and Docker Compose
      yum install -y docker
      curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose
      service docker start
      chkconfig docker on

      # Pull the Docker image from Docker Hub for the app
      sudo docker pull tom621/stock-price-prediction:FV

      # Remove any existing containers
      sudo docker rm -f my_app_container

      # Run the Docker container for the app
      sudo docker run -d --name my_app_container \
        -p 5001:5001 \
        -p 8000:8000 \
        -e MONGO_URI=mongodb://<external-mongo-host>:27017/ \
        tom621/stock-price-prediction:FV

      # Clone the Git repository for Loki and Promtail setup
      cd /home/ec2-user
      git clone https://github.com/yourusername/loki-promtail-setup.git
      cd loki-promtail-setup

      # Run Docker Compose for Loki and Promtail
      docker-compose up -d



      EOF
    }
    "instance-private-2" = {
      user_data = <<-EOF
      #!/bin/bash

      # Update the system packages
      yum update -y

      # Install Docker and Docker Compose
      yum install -y docker
      curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose
      service docker start
      chkconfig docker on

      # Pull the Docker image from Docker Hub for the app
      sudo docker pull tom621/stock-price-prediction:FV

      # Remove any existing containers
      sudo docker rm -f my_app_container

      # Run the Docker container for the app
      sudo docker run -d --name my_app_container \
        -p 5001:5001 \
        -p 8000:8000 \
        -e MONGO_URI=mongodb://<external-mongo-host>:27017/ \
        tom621/stock-price-prediction:FV

      # Clone the Git repository for Loki and Promtail setup
      cd /home/ec2-user
      git clone https://github.com/yourusername/loki-promtail-setup.git
      cd loki-promtail-setup

      # Run Docker Compose for Loki and Promtail
      docker-compose up -d



      EOF
    }
    "instance-private-3" = {
      user_data = <<-EOF
      #!/bin/bash
        sudo yum update -y
        sudo yum install -y git
        sudo yum install -y docker
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        sudo usermod -a -G docker ec2-user
        sudo service docker start
        sudo chkconfig docker on
        sudo git clone https://github.com/rindjon/sys_monitoring.git /home/ec2-user/sys_monitoring
        cd /home/ec2-user/sys_monitoring
        # INSTANCE_PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
        # sudo echo $INSTANCE_PUBLIC_IP > /etc/domain_name
        sudo chmod +x ./replace_domain.sh
        sudo chmod +x ./prometheus/adjust_mon_targets.sh
        # sudo ./replace_domain.sh
        # sudo ./prometheus/adjust_mon_targets.sh
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
        # sudo docker-compose up -d
        sudo touch /etc/mon_target_inst_ip

      EOF
    }
    "instance-private-4" = {
      user_data = <<-EOF
      #!/bin/bash

      # Update the system packages
      yum update -y

      # Install Docker
      yum install -y docker

      # Start and enable Docker service
      sudo service docker start
      sudo chkconfig docker on

      # Pull MongoDB and Mongo Express images
      sudo docker pull mongo:latest
      sudo docker pull mongo-express:latest

      # Create a Docker network for MongoDB and Mongo Express
      sudo docker network create mongo-network

      # Remove any existing MongoDB container (if exists)
      sudo docker rm -f mongodb

      # Run MongoDB container on the created Docker network with persistent storage
      sudo docker run -d --name mongo --network mongo-network -p 27017:27017 \
        -v mongo_data:/data/db \
        mongo:latest

      # Remove any existing Mongo Express container (if exists)
      sudo docker rm -f mongo-express

      # Run Mongo Express container on the created Docker network and link it to MongoDB
      sudo docker run -d --name mongo-express --network mongo-network -p 8081:8081 \
        -e ME_CONFIG_MONGODB_ADMINUSERNAME=admin \
        -e ME_CONFIG_MONGODB_ADMINPASSWORD=password \
        mongo-express:latest



      EOF
    }
  }
}
