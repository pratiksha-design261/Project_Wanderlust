# create the new key-pair on console from data recived from pub key on local
resource "aws_key_pair" "TF_To_EC2_key" {
  key_name = "TF_to_EC2_key"
  public_key = file("/home/root1/Downloads/Edge_Downloads/Keys/TF_to_EC2_key.pub")
}

# Create VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tf-vpc"
  }
}

#Create public Subnet1 and attach to VPC
resource "aws_subnet" "tf_sub1" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
}

#Create public Subnet2 and attach to VPC
resource "aws_subnet" "tf_sub2" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "172.16.20.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true
}

 # create Internet gateway and attach to VPC
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id
}

# Create Route table attach to vpc and set route throught IGW
resource "aws_route_table" "tf_rt" {
  vpc_id = aws_vpc.tf_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }
}

# attach RT to Subnet
resource "aws_route_table_association" "tf_rt_associate1" {
  subnet_id = aws_subnet.tf_sub1.id
  route_table_id = aws_route_table.tf_rt.id
}

# attach RT to Subnet
resource "aws_route_table_association" "tf_rt_associate2" {
  subnet_id = aws_subnet.tf_sub2.id
  route_table_id = aws_route_table.tf_rt.id
}

# create SG and attach VPC to it
resource "aws_security_group" "tf_sg" {
  name = "Wanderlust_project_SG"
  vpc_id = aws_vpc.tf_vpc.id
  description = "This SG will set the inbound and outbound rules for wanderlust application"

  # Inbound Rules
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "jenkins"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "sonarqube"
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "Docker_frontend"
    from_port = 31000
    to_port = 31000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "Docker_backend"
    from_port = 31100
    to_port = 31100
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "Docker_database"
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # Outbound Rules
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  

    tags = {
    Name = "Wanderlust_project_SG"
  }
}

# Create EC2 Instance
resource "aws_instance" "node_instance" {
  
  ami = var.ami_ID
  instance_type = var.ec2_type
  key_name = aws_key_pair.TF_To_EC2_key.key_name
  vpc_security_group_ids = [aws_security_group.tf_sg.id]
  subnet_id = aws_subnet.tf_sub1.id
  tags = {
    name = "TF_master_node_instance"
  }
    
    # Allocate EBC volume to instance
    root_block_device {
    volume_size = 30 
    volume_type = "gp3"
  }
}

# create Load balancer to manage traffic 
resource "aws_lb" "tf_lb" {
  name               = "tf-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf_sg.id]
  subnets            = [aws_subnet.tf_sub1.id, aws_subnet.tf_sub2.id]
}

# create target group for load balancer on which port our application is running
resource "aws_lb_target_group" "tf_sg_tg" {
  name     = "sg-tg"
  port     = 31000
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf_vpc.id

   health_check {
    path = "/"
    port = "traffic-port"
  }

}

# This specific block connects the EC2 instance with the target group, allowing traffic to flow from the load balancer to the instance.
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tf_sg_tg.arn
  target_id        = aws_instance.node_instance.id
  port             = 31000
}

# A listener is a process that checks for connection requests based on the protocol and port defined. When a request is received, it forwards the traffic to the appropriate target group.
resource "aws_lb_listener" "tf_listener" {
  load_balancer_arn = aws_lb.tf_lb.arn
  port              = 31000
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tf_sg_tg.arn
    type             = "forward"
  }
}
