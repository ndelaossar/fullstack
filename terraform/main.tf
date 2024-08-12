resource "aws_s3_bucket" "fullstack" {
  bucket        = "fullstack-challenge-${var.env_tf}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "fullstack" {
  bucket = aws_s3_bucket.fullstack.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "versioning_fullstack" {
  bucket = aws_s3_bucket.fullstack.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "fullstack-website" {
  bucket = aws_s3_bucket.fullstack.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
  lifecycle {
   prevent_destroy = true
 }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.fullstack.id
  policy = data.aws_iam_policy_document.allow_web_access.json
}

data "aws_iam_policy_document" "allow_web_access" {
  statement {
    sid = "PublicReadGetObject"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.fullstack.arn}/*",
    ]
  }
}

# Sync files
resource "aws_s3_bucket_object" "object" {
  for_each = fileset("nodejs-build/", "**/*.*")
  bucket   = aws_s3_bucket.fullstack.id
  key      = each.value
  source   = "nodejs-build/${each.value}"

  depends_on = [aws_s3_bucket.fullstack]
}