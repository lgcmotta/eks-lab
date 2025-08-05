data "aws_autoscaling_group" "this" {
  name = var.node_group_asg_name
}

data "aws_instances" "this" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [var.node_group_asg_name]
  }

  instance_state_names = ["running"]
}

resource "aws_security_group" "this" {
  name   = "${var.name}-alb-sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each                     = toset(var.cluster_security_group_ids)
  security_group_id            = aws_security_group.this.id
  ip_protocol                  = "tcp"
  from_port                    = 32080
  to_port                      = 32080
  referenced_security_group_id = each.key
}

resource "aws_vpc_security_group_ingress_rule" "node" {
  for_each                     = toset(var.cluster_security_group_ids)
  security_group_id            = each.key
  ip_protocol                  = "tcp"
  from_port                    = 32080
  to_port                      = 32080
  referenced_security_group_id = aws_security_group.this.id
}

resource "aws_vpc_security_group_egress_rule" "health" {
  for_each                     = toset(var.cluster_security_group_ids)
  security_group_id            = aws_security_group.this.id
  ip_protocol                  = "tcp"
  from_port                    = 32081
  to_port                      = 32081
  referenced_security_group_id = each.key
}

resource "aws_vpc_security_group_ingress_rule" "health" {
  for_each                     = toset(var.cluster_security_group_ids)
  security_group_id            = each.key
  ip_protocol                  = "tcp"
  from_port                    = 32081
  to_port                      = 32081
  referenced_security_group_id = aws_security_group.this.id
}

resource "aws_lb" "this" {
  name                       = var.name
  internal                   = false
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  enable_deletion_protection = false
  enable_xff_client_port     = true
  security_groups            = [aws_security_group.this.id]
  subnets                    = var.subnet_ids
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name}-tg"
  port     = 32080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    port                = "32081"
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each         = toset(data.aws_instances.this.ids)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.value
  port             = 32080
}
