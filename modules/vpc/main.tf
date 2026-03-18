resource "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "fct_vpc"
    }
}
resource "aws_subnet" "subnet" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.subnet_cidr
    availability_zone = var.az
    tags = {
        Name = "public_subnet"
    }
}
