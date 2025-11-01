terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 4.0" }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "media_bucket" {
  bucket = "media-streaming-app-bucket"
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.media_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "media-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true

  origin {
    domain_name              = aws_s3_bucket.media_bucket.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_dynamodb_table" "media_metadata" {
  name         = "media_metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "media_id"

  attribute {
    name = "media_id"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "media_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "media_lambda" {
  function_name = "mediaHandler"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda_function.zip"

  environment {
    variables = {
      DYNAMO_TABLE = aws_dynamodb_table.media_metadata.name
      BUCKET_NAME  = aws_s3_bucket.media_bucket.id
    }
  }
}

resource "aws_api_gateway_rest_api" "media_api" {
  name = "media-api"
}

resource "aws_api_gateway_resource" "media" {
  rest_api_id = aws_api_gateway_rest_api.media_api.id
  parent_id   = aws_api_gateway_rest_api.media_api.root_resource_id
  path_part   = "media"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.media_api.id
  resource_id   = aws_api_gateway_resource.media.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.media_api.id
  resource_id             = aws_api_gateway_resource.media.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.media_lambda.invoke_arn
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.media_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.media_api.execution_arn}/*/*"
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "api_url" {
  value = aws_api_gateway_rest_api.media_api.execution_arn
}

