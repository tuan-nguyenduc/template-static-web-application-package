variable "bucket" {
  description = "The name of the S3 bucket to be created for the website."
  type        = string
}


variable "use_existed_route53_hosted_zone" {
  description = "Flag to determine if an existing Route 53 hosted zone should be used."
  type        = bool
  default     = false
}

variable "aliases" {
  description = "A list of aliases (CNAMEs) to associate with the CloudFront distribution."
  type        = list(string)
  default     = []
}

variable "route53_hosted_zone_configs" {
  description = "Configuration for Route 53 hosted zone. Includes the hosted zone ID and sub-domain name."
  type = object({
    hosted_zone_id  = string
    sub_domain_name = string
  })
  default = null
}