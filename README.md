# terraform-aws-basic
The goal of this project is to spin up basic infrastructure on [Amazon Web Services](http://aws.amazon.com/) (AWS), consisting of 3 EC2 instances (2 private & 1 bastion host), using [Terraform](http://terraform.io).

## Configurations
This code will spin up a few AWS resources, namely:
1. Private VPC
2. 2 Subnets
3. 2 Route Tables
4. Internet Gateway
5. NAT Gateway
6. 2 Security Groups
7. 1 EC2 Key Pair
8. 3 EC2 Instances

The purpose of this code is to simulate a basic working infrastructure of an appserver & webserver in a private subnet, and a bastion host in a public subnet that is able to reach these 2 instances. 

## Usage
1. Download all the files in a directory
2. Put in your Access Key & Secret Key in provider.tf
3. Run 'terraform init' in the directory
4. Run 'terraform plan' to check if the output is satisfactory
5. Run 'terraform apply' to apply the resources
6. When you are done with the resources, run 'terraform destroy' to destroy all resources
