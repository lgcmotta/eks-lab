terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws.region
  default_tags {
    tags = var.aws.tags
  }
}

module "acm" {
  source = "../../modules/acm"
  domain = var.route53.domain
  zone   = var.route53.zone
}

module "alb" {
  source          = "../../modules/alb"
  certificate_arn = module.acm.acm_certificate_arn
  name            = var.alb.name
  vpc_id          = var.vpc.id
  subnet_ids      = var.vpc.public_subnet_ids
  depends_on      = [module.acm]
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = {
    for pair in setproduct(var.services.security_group_ids, var.rancher.security_group_ids) : pair[0] => pair[1]
  }
  security_group_id            = each.key
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = each.value
}

module "target_group" {
  source   = "../../modules/target-group"
  for_each = { for _, target in var.targets : target.name => target }
  vpc_id   = var.vpc.id
  zone     = var.route53.zone
  name     = each.key
  dns      = each.value.dns
  load_balancer = {
    arn               = module.alb.arn
    listener_arn      = module.alb.https_listener_arn
    security_group_id = module.alb.security_group_id
    rule_priority     = each.value.rule_priority
    dns_name          = module.alb.dns_name
    zone_id           = module.alb.zone_id
  }
  cluster = {
    security_group_ids     = each.value.cluster.security_group_ids
    autoscaling_group_name = each.value.cluster.autoscaling_group_name
  }
  ports = {
    health_check = each.value.ports.health_check
    http         = each.value.ports.http
  }
}
