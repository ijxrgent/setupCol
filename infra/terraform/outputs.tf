output "site_url" {
  description = "URL del sitio"
  value       = local.use_custom_domain ? "https://${var.domain_name}" : "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "s3_bucket" {
  description = "Va en la variable S3_BUCKET de GitHub"
  value       = aws_s3_bucket.site.bucket
}

output "cloudfront_distribution_id" {
  description = "Va en la variable CLOUDFRONT_DISTRIBUTION_ID de GitHub"
  value       = aws_cloudfront_distribution.site.id
}

output "github_deploy_role_arn" {
  description = "Va en la variable AWS_ROLE_ARN de GitHub"
  value       = aws_iam_role.github_deploy.arn
}
