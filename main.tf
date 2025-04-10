provider "aws" {
  region = "us-east-1"
}
module "network" {
  source = "./network-tf"
}