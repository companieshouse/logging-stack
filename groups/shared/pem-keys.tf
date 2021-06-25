resource "aws_key_pair" "logging-stack" {
  key_name   = local.ssh_keyname
  public_key = var.ssh_public_key
}
