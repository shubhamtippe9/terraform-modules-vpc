provider "aws" {
    region = "us-east-1"
} 
module "vpc" {
    source = "./modules/vpc"
}
module "subnet" {
    source = "./modules/vpc/subnet"            
}
