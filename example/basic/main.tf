module "simple_static_web" {
  source                          = "../.."
  bucket                          = "test-bucket-tuannd"
  use_existed_route53_hosted_zone = true
  route53_hosted_zone_configs = {
    hosted_zone_id  = "Z01191853KECZ31X24NQT"
    sub_domain_name = "website"
  }
  aliases = []
}