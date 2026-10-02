data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

# Origin Access Control : CloudFront signe ses requetes vers S3 (SigV4).
# Associe a la politique du bucket, il empeche tout acces direct a S3.
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.project_name}-oac"
  description                       = "Acces signe de CloudFront au bucket prive MediTrack"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "MediTrack Online - site statique (GreenOps Solutions)"
  default_root_object = "index.html"

  # PriceClass_100 : points de presence Europe / Amerique du Nord (le moins cher,
  # adapte a une clientele d'hopitaux et cliniques en Europe)
  price_class = "PriceClass_100"

  # Origine : le bucket S3 prive (point de terminaison REST regional)
  origin {
    origin_id                = "s3-${aws_s3_bucket.site.id}"
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id = "s3-${aws_s3_bucket.site.id}"

    # Toute requete HTTP est redirigee vers HTTPS (code 301)
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    cache_policy_id = data.aws_cloudfront_cache_policy.optimized.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Certificat TLS fourni et renouvele automatiquement par CloudFront
  # pour le domaine *.cloudfront.net (HTTPS sans nom de domaine achete).
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.project_name}-cdn"
  }
}
