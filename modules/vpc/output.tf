output "subnet_id" {
    value = aws_subnet.subnet.id
}
output "vpc_id" {
    value = aws_vpc.main_vpc.id
}