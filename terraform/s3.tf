# s3.tf - Bucket S3 d'hebergement du site statique MediTrack Online

locals {
  bucket_name = "${var.project_name}-site-${data.aws_caller_identity.current.account_id}"

  # Dossier du site statique dans le depot
  site_dir = "${path.module}/../site"

  mime_types = {
    ".html" = "text/html; charset=utf-8"
    ".svg"  = "image/svg+xml"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
  }
}

resource "aws_s3_bucket" "site" {
  bucket = local.bucket_name

  tags = {
    Name = local.bucket_name
  }
}

# Blocage de TOUT acces public au bucket
resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configuration "site web statique" : page d'accueil.
# Le site est diffuse par CloudFront (origine S3 privee + OAC) ; le point de terminaison web public de S3 reste ferme par le blocage d'acces public.
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
}

# Politique du bucket : lecture autorisee UNIQUEMENT pour notre distribution CloudFront
data "aws_iam_policy_document" "site_bucket" {
  statement {
    sid       = "AutoriserCloudFrontUniquement"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site_bucket.json

  depends_on = [aws_s3_bucket_public_access_block.site]
}

# Envoi automatique des fichiers du site dans le bucket.
# etag = empreinte MD5 : un fichier modifie est automatiquement renvoye.
resource "aws_s3_object" "site_files" {
  # Les fichiers systeme macOS (.DS_Store) sont exclus de l'envoi
  for_each = toset([for f in fileset(local.site_dir, "**") : f if !endswith(f, ".DS_Store")])

  bucket       = aws_s3_bucket.site.id
  key          = each.value
  source       = "${local.site_dir}/${each.value}"
  etag         = filemd5("${local.site_dir}/${each.value}")
  content_type = lookup(local.mime_types, lower(regex("\\.[^.]+$", each.value)), "application/octet-stream")
}
