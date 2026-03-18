variable "ami_id" {
    default = "ami-02dfbd4ff395f2a1b"
}
variable "insatnce_type" {
    default = "t3.micro"  
}
 variable "subnet_id" {
    description = "Enter a subnet id"
 }
 variable "vpc_id" {
    description = "Enter a vpc id"
 }