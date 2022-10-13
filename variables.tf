variable "private_instances_names" {
  type    = list(any)
  default = ["terraform-appserver", "terraform-webserver", "terraform-dbserver"]
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}
