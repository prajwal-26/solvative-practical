# Provider variables
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

# S3 Bucket variables
variable "bucket_name" {
  description = "Name of S3 bucket for storing media files"
  type        = string
  default     = "media-streaming-app-bucket"
}

# DynamoDB Table variables
variable "table_name" {
  description = "Name of the DynamoDB table for metadata"
  type        = string
  default     = "MediaMetadata"
}

# Lambda Function variables
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "media-api-lambda"
}

variable "lambda_handler" {
  description = "Lambda function handler"
  type        = string
  default     = "index.handler"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.9"
}

variable "lambda_s3_key" {
  description = "S3 key for the Lambda deployment package"
  type        = string
  default     = "lambda/media-api.zip"
}

# API Gateway variables
variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "media-streaming-api"
}

# CloudFront variables
variable "cloudfront_origin_id" {
  description = "Origin ID for CloudFront distribution"
  type        = string
  default     = "S3-origin"
}

