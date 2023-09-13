variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "private_ip" {
  type = string
}

variable "ports" {
  type = list(number)
}

variable "public_ip" {
  type = bool
}