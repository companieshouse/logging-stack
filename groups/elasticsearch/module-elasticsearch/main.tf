data "aws_ami" "elasticsearch" {
  owners      = ["self"]
  most_recent = true
  name_regex  = "^elasticsearch-ami-${var.ami_version_pattern}$"

  filter {
    name   = "name"
    values = ["elasticsearch-ami-*"]
  }
}
