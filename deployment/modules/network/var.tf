variable "name" {
  type = string
  default = "tf"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "subnets" {
    type = map(string)
    default = {
      lab: "10.0.0.0/24",
      blue: "10.0.10.0/24"
      red: "10.0.20.0/24",
      vpn: "10.0.50.0/24"
    }
}
