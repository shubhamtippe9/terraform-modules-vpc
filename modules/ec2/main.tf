resource "aws_instance" "name" {
    ami = var.ami_id
    instance_type = var.insatnce_type
    vpc_security_group_ids = [aws_security_group.sg.id]
    subnet_id = var.subnet_id
    tags = {
        Name = my_ec2
    }
} 
resource "aws_security_group" "name" {
    description = "allow ssh"
    vpc_id = var.vpc_id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
    }
  ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = new_sg
    }
}