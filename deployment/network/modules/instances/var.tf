variable "name" {
  type = string
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
    public_ip     = bool
    volume_size   = number
    ports = list(object({
      port        = number
      protocol    = string
      cidr_blocks = list(string)
    }))
  }))
}
