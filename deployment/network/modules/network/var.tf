variable "name" {
  type    = string
  default = "tf"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnets" {
  type = map(string)
}
