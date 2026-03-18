provider "aws" {
    region = "us-east-1"
} 
module "vpc" {
    source = "./modules/vpc"
}
module "subnet" {
    source = "./modules/ec2"
    subnet_id = module.vpc.subnet_id
    vpc_id = module.vpc.vpc_id 
}
