data "aws_cloudfront_cache_policy" "noCache" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "cacheEnabled" {
  name = "Managed-CachingOptimized"
}

data "aws_ssm_parameter" "https_certification_arn" {
  name = "/${var.project_name}/${var.environment}/web_alb_certificate_arn"
}