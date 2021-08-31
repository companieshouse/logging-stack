data "aws_ami" "elasticsearch" {
  for_each = local.ami_version_patterns

  owners      = [var.ami_owner_id]
  most_recent = true
  name_regex  = "^elasticsearch-ami-${each.value}$"

  filter {
    name   = "name"
    values = ["elasticsearch-ami-*"]
  }
}
