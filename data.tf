data "aws_caller_identity" "current" {}

data "aws_route53_zone" "this" {
  count   = var.use_existed_route53_hosted_zone ? 1 : 0
  zone_id = var.route53_hosted_zone_configs.hosted_zone_id
}