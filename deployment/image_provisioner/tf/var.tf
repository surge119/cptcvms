variable "name" {
  type    = string
  default = "cptc_image-provisioner"
}

variable "ports" {
  type    = list(number)
  default = [22, 8080]
}

variable "instance_type" {
  type    = string
  default = "c7g.large"
}

variable "ami" {
  type = string
  // Ubuntu
  // default = "ami-053b0d53c279acc90"
  default = "ami-0a0c8eebcdd6dcbd0"
}
