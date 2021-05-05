data "aws_ami" "elasticsearch" {
  owners      = ["${var.ami_owner_id}"]
  most_recent = true
  name_regex  = "^elasticsearch-ami-${var.ami_version_pattern}$"

  filter {
    name   = "name"
    values = ["elasticsearch-ami-*"]
  }
}
