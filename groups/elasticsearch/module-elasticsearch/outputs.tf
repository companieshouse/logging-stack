output "cold_node_ips" {
  value = aws_instance.data_cold.*.private_ip
}
