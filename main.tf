##################################################################
# S3
##################################################################
module "s3_website" {
  source        = "./local_modules/s3"
  bucket        = var.bucket
  acl           = "private"
  force_destroy = true

  # S3 Bucket Ownership Controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  # S3 bucket-level Public Access Block configuration (by default now AWS has made this default as true for S3 bucket-level block public access)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Versioning
  versioning = {
    status     = true
    mfa_delete = false
  }

  attach_policy = true
  policy = templatefile("${path.module}/templates/s3_website_bucket_policy.json", {
    bucket_name = var.bucket
    cf_oai_arn  = module.cloudfront.cloudfront_origin_access_identity_iam_arns[0]
  })

  logging = {
    target_bucket = module.s3_log.s3_bucket_id
    target_prefix = "logs-${var.bucket}/"
    target_object_key_format = {
      partitioned_prefix = {
        partition_date_source = "DeliveryTime" # "EventTime"
      }
    }
  }

  cors_rule = [
    {
      allowed_methods = ["PUT", "POST"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
      }, {
      allowed_methods = ["PUT"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]
}

module "s3_log" {
  source = "./local_modules/s3"

  bucket        = "logs-${var.bucket}"
  force_destroy = true

  control_object_ownership = true

  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_access_log_delivery_policy     = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  access_log_delivery_policy_source_accounts = [data.aws_caller_identity.current.account_id]
  access_log_delivery_policy_source_buckets  = ["arn:aws:s3:::${var.bucket}"]
}

##################################################################
# CloudFront
##################################################################
module "cloudfront" {
  source  = "./local_modules/cloudfront"
  aliases = var.use_existed_route53_hosted_zone ? concat(["*.${data.aws_route53_zone.this[0].name}"], try(var.aliases, null)) : []

  comment                       = "Cloudfront distribution for ${var.bucket} website."
  enabled                       = true
  create_origin_access_identity = true
  default_root_object           = "index.html"
  origin_access_identities = {
    s3_website = "${var.bucket} S3 website access identity."
  }
  origin = {
    s3_website = {
      domain_name = module.s3_website.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_website"
      }
    }
  }
  default_cache_behavior = {
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # Managed-CORS-S3Origin
    target_origin_id         = "s3_website"
    viewer_protocol_policy   = "allow-all"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    compress                 = false
    query_string             = false
    use_forwarded_values     = false
  }

  viewer_certificate = var.use_existed_route53_hosted_zone ? {
    acm_certificate_arn            = module.acm.acm_certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
    } : {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}


##################################################################
# Route53 Records + ACM
##################################################################
module "records" {
  source  = "./local_modules/route53/records"
  create  = var.use_existed_route53_hosted_zone
  zone_id = try(var.route53_hosted_zone_configs.hosted_zone_id, null)
  records = var.use_existed_route53_hosted_zone ? [
    {
      name    = var.route53_hosted_zone_configs.sub_domain_name
      type    = "CNAME"
      records = [module.cloudfront.cloudfront_distribution_domain_name]
      ttl     = 3600
    },
  ] : []

}

module "acm" {
  source              = "./local_modules/acm"
  create_certificate  = var.use_existed_route53_hosted_zone
  domain_name         = try("*.${data.aws_route53_zone.this[0].name}", "")
  zone_id             = try(var.route53_hosted_zone_configs.hosted_zone_id, null)
  validation_method   = "DNS"
  wait_for_validation = true
}
