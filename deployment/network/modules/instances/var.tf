variable "name" {
  type    = string
  default = "tf"
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "instances" {
  type = list(object({
    name          = string
    ami           = string
    instance_type = string
    subnet_id     = string
    private_ip    = string
    ports         = list(number)
    public_ip     = bool
  }))
}
