variable "name" {
  type    = string
  default = "tf"
}

variable "vpc_cidr" {
  type = string
}

variable "subnets" {
  type = map(string)
}
