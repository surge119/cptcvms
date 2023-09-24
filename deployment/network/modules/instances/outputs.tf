output "instances" {
  value = [
    for instance in aws_instance.instance : {
      id = instance.id
      ip = instance.public_ip
    }
  ]
}
