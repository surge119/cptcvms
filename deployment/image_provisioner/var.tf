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
  default = "c6in.8xlarge"
}

variable "ami" {
  type = string
  // Ubuntu
  default = "ami-053b0d53c279acc90"
}
