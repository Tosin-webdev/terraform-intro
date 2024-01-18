provider "aws" {

}

variable "cidr_blocks" {
    description= "cidr blocks and name tags for vpc and subnets"
    type = list(object ({
        cidr_block = string
        name = string
    })) 
} 

    # availability_zone = "us-east-1a"
variable avail_zone {

}
# variable "subnet_cidr_block"{
#     description= "subnet cidr block"
#     default = "10.0.10.0/24"
#     # "10.0.10.0/24"
# } 

# variable "vpc_cidr_block" {
#     description= "vpc cidr block" 
# }

# variable "environment" {
#     description = "deployment environment"
# }

resource "aws_vpc" "development-vpc" {
    # cidr_block = "10.0.0.0/16"
    cidr_block = var.cidr_blocks[0].cidr_block
    # give name to resources
    tags = {
        Name: var.cidr_blocks[0].name,
        # Name: var.environment 
        vpc_env: "dev"
    }
} 

resource "aws_subnet" "dev-subnet-1"{
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: var.cidr_blocks[1].name,
    }
}


output "dev-vpx-id" {
    value = aws_vpc.development-vpc.id
}

output "dev-subnet-id"{
    value = aws_subnet.dev-subnet-1.id
}



