variable "load_balancer" {
  type = object({
    arn               = string
    security_group_id = string
    listener_arn      = string
    rule_priority     = number
    dns_name          = string
    zone_id           = string
  })
}

variable "ports" {
  type = object({
    health_check = number
    http         = number
  })
}

variable "cluster" {
  type = object({
    security_group_ids     = list(string)
    autoscaling_group_name = string
  })
}

variable "zone" {
  type = string
}

variable "dns" {
  type = string
}

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each                     = toset(var.cluster.security_group_ids)
  security_group_id            = each.key
  ip_protocol                  = "tcp"
  from_port                    = var.ports.http
  to_port                      = var.ports.http
  referenced_security_group_id = var.load_balancer.security_group_id
}

resource "aws_vpc_security_group_egress_rule" "http" {
  for_each                     = toset(var.cluster.security_group_ids)
  security_group_id            = var.load_balancer.security_group_id
  ip_protocol                  = "tcp"
  from_port                    = var.ports.http
  to_port                      = var.ports.http
  referenced_security_group_id = each.key
}

resource "aws_vpc_security_group_ingress_rule" "health" {
  for_each                     = toset(var.cluster.security_group_ids)
  security_group_id            = each.key
  ip_protocol                  = "tcp"
  from_port                    = var.ports.health_check
  to_port                      = var.ports.health_check
  referenced_security_group_id = var.load_balancer.security_group_id
}

resource "aws_vpc_security_group_egress_rule" "health" {
  for_each                     = toset(var.cluster.security_group_ids)
  security_group_id            = var.load_balancer.security_group_id
  ip_protocol                  = "tcp"
  from_port                    = var.ports.health_check
  to_port                      = var.ports.health_check
  referenced_security_group_id = each.key
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name}-tg"
  port     = var.ports.http
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    port                = tostring(var.ports.health_check)
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.load_balancer.listener_arn
  priority     = var.load_balancer.rule_priority
  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.this.arn
      }
      stickiness {
        duration = 3600
      }
    }
  }
  condition {
    host_header {
      values = [var.dns]
    }
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = var.cluster.autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.this.arn
}

data "aws_route53_zone" "this" {
  name         = var.zone
  private_zone = false
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.dns
  type    = "A"
  alias {
    name                   = var.load_balancer.dns_name
    zone_id                = var.load_balancer.zone_id
    evaluate_target_health = false
  }
}
