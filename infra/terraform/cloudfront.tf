locals {
  use_custom_domain = var.domain_name != ""
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.project}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Astro genera /guias/x/index.html. S3 (por API) no resuelve "index.html" solo,
# así que esta función reescribe /guias/x/ -> /guias/x/index.html antes de ir a S3.
resource "aws_cloudfront_function" "rewrite_index" {
  name    = "${var.project}-rewrite-index"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = <<-EOT
    function handler(event) {
      var request = event.request;
      var uri = request.uri;
      if (uri.endsWith('/')) {
        request.uri += 'index.html';
      } else if (!uri.includes('.')) {
        // /ofertas -> redirige a /ofertas/ (trailingSlash: 'always' en Astro)
        return {
          statusCode: 301,
          statusDescription: 'Moved Permanently',
          headers: { location: { value: uri + '/' } }
        };
      }
      return request;
    }
  EOT
}

# Política administrada por AWS: "Managed-CachingOptimized"
data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project} sitio estatico"
  default_root_object = "index.html"
  aliases             = local.use_custom_domain ? [var.domain_name] : []

  # PriceClass_All incluye los edge de Sudamérica (Bogotá). Con tráfico bajo la diferencia de costo es mínima.
  price_class = "PriceClass_All"

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-site"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-site"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.optimized.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rewrite_index.arn
    }
  }

  # Con OAC, S3 responde 403 cuando un archivo no existe -> mostramos nuestra 404
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = local.use_custom_domain ? false : true
    acm_certificate_arn            = local.use_custom_domain ? aws_acm_certificate_validation.site[0].certificate_arn : null
    ssl_support_method             = local.use_custom_domain ? "sni-only" : null
    minimum_protocol_version       = local.use_custom_domain ? "TLSv1.2_2021" : "TLSv1"
  }
}
