output "cloudfront_domain_name" {
  value = module.cloudfront.cloudfront_distribution_domain_name
}

output "website_bucket_domain_name" {
  value = module.s3_website.s3_bucket_bucket_domain_name
}

output "website_bucket_arn" {
  value = module.s3_website.s3_bucket_arn
}

output "logging_bucket_domain_name" {
  value = module.s3_log.s3_bucket_bucket_domain_name
}

output "logging_bucket_arn" {
  value = module.s3_log.s3_bucket_arn
}