# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.0.0"
      }
    }
}

provider "aws" {
    region = "us-east-1"
    aws_access_key_id=ASIAZQ3DQNKQK6G76KWO
    aws_secret_access_key=MyhCMH9LIYjsrmOkC0epNrdYFHpiu5ITlEn/Wzhu
    aws_session_token=IQoJb3JpZ2luX2VjEM7//////////wEaCXVzLXdlc3QtMiJHMEUCIQDerxqbafKLrn/2FPU0Mv1k6koCFEmmxA55OjUgm/EuRgIgTcLE3sInbJUacW3+2txxJ0IXZfXPVNkzkeXuOzQw2aMqpgIIFxAAGgw2NTQ2NTQzMzU2NDgiDGqYPQC6QOJbqm9isyqDAimf1drI5WHc6+tp5scWnO6TgpXzW46cYPkqUVGQwt37iI/F+3mzgZSgXazqMLkqc1/vQW3dI1aI+8ltf/s7tegXKqq94HPP3xtUH1vpdHQuj2DRDN57ZYG04UtyuKAEOtHvky/722pbbU7XvPF6YMm+qJp+HJyVNmaXwKFMn1e16hoR8iqSfBILP9+JjjE3AQUhlXR9TcH4UlM9wTDzaoyMhyaGBMNNvXHy3GiuzMLIbLFbTnH1DosFljB0eB6hElCeii2hf6ASy2C0YDJnE2DnuOEivLxZrtMgDX9hloa0jV1uXppOfhAk7lb2V3m2ih8qOpxL+Q2Z0gIfDixMR6pjzYgwweqJsQY6nQFfruOCmqBF8q9gbbnM4dYgIVk99XZ6C/hzCY6fvr6xPnflj5mCEwqMdOt0v+pz4nJ7EiURQAMwbyQ08aqHKkhHDbDb+CUWLADUEwzDqOsLzPjX7YNUkXb2hlWQs7VUZLsLhAz5ERx/fr52LXaTP2VpT7JOnPKcvnlqlnKWkd4szpoR16r6cTtZJ/WRkC8jLzmKdG3a3Gwf+uuLPx8O
}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${var.prefix}-${var.name}"

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_website_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [
    aws_s3_bucket_public_access_block.bucket,
    aws_s3_bucket_ownership_controls.bucket,
  ]
  bucket = aws_s3_bucket.bucket.id

  acl = "public-read"
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_object" "webapp" {
  acl          = "public-read"
  key          = "index.html"
  bucket       = aws_s3_bucket.bucket.id
  content      = file("${path.module}/assets/index.html")
  content_type = "text/html"
}
