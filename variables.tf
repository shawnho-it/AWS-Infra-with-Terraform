variable "private_instances_names" {
  type    = list(any)
  default = ["terraform-appserver", "terraform-webserver", "terraform-dbserver"]
}
