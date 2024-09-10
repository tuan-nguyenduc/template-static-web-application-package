output "cloudfront_domain_name" {
  value = module.simple_static_web.cloudfront_domain_name
}

output "website_bucket_domain_name" {
  value = module.simple_static_web.website_bucket_domain_name
}

output "website_bucket_arn" {
  value = module.simple_static_web.website_bucket_arn
}

output "logging_bucket_domain_name" {
  value = module.simple_static_web.logging_bucket_domain_name
}

output "logging_bucket_arn" {
  value = module.simple_static_web.logging_bucket_arn
}