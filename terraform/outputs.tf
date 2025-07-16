output "instance_id" {
  value = aws_instance.ib_gateway.id
}

output "public_ip" {
  value = aws_instance.ib_gateway.public_ip
}
