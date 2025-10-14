data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["platform-vpc"]

  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  filter {
    name   = "tag:Type"
    values = ["Public"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  filter {
    name   = "tag:Type"
    values = ["Private"]
  }
}

data "aws_lb" "existing" {
  name = var.load_balancer_name
}

data "aws_lb_target_group" "existing" {
  name = var.target_group_name
}


