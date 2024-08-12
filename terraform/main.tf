resource "aws_s3_bucket" "fullstack" {
  bucket        = "fullstack-challenge-${var.env_tf}"
  force_destroy = true
}

# resource "aws_s3_bucket_acl" "fullstack-acl" {
#   bucket = aws_s3_bucket.fullstack.id
#   acl    = "private"
# }

resource "aws_s3_bucket_versioning" "versioning_fullstack" {
  bucket = aws_s3_bucket.fullstack.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "fullstack" {
  bucket = aws_s3_bucket.fullstack.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

}

resource "aws_s3_bucket_object" "object" {
  for_each = fileset("nodejs-build/", "**/*.*")
  bucket   = aws_s3_bucket.fullstack.id
  key      = each.value
  source   = "nodejs-build/${each.value}"

  depends_on = [aws_s3_bucket.fullstack]
}