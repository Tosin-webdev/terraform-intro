provider "aws"{
    region = "us-east-1"
}

variable vpc_cidr_block {}

variable subnet_cidr_block {}

variable env_prefix {}

variable avail_zone {}

variable my_ip {}

variable instance_type {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    # give name to resources
    tags = {
        Name: "${var.env_prefix}-vpc",
    }
} 

resource "aws_subnet" "myapp-subnet-1"{
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1",
    }
}

# resource "aws_route_table" "myapp-route-table"{
#     vpc_id = aws_vpc.myapp-vpc.id
#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.myapp-igw.id
#     }
#     tags = {
#         Name: "${var.env_prefix}-rtb"
#     } 
# }

resource "aws_internet_gateway" "myapp-igw"{
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    } 
}

# resource "aws_route_table_association" "a-rtb-subnet" {
#     subnet_id = aws_subnet.myapp-subnet-1.id
#     route_table_id = aws_route_table.myapp-route-table.id
# }

# when referencing a new route table we dont need a VPC id
resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-main-rtb"
    } 
}

resource "aws_default_security_group" "default-sg"{
    # name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-default-sg"
    } 
}

data "aws_ami" "latest-amazon-linux-image"{
    most_recent = true 
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm*"]
    }
    # filter {
    #     name = "virtualization"
    #     values = ["hvm"]
    # }
}
# Amazon Linux 2 Kernel 5.10 AMI 2.0.20240109.0 x86_64 HVM gp2
output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_instance" "myapp-server"{
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type
}

