terraform {
  backend "s3" {
    bucket = "terraform-state" # Name of the S3 bucket
    endpoints = {
      s3 = "http://minio-api.ddimtech-dev.com" # Minio endpoint
    }
    key = "tfstate-local" # Name of the tfstate file

    access_key = "495aVTYinnM7k70UTG97" # Access and secret keys
    secret_key = "xU7nXeLhvIB6rouejpTO8gHgvXVG2mn4tDai7O49"

    region                      = "main"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}

provider "local" {}

# 리소스 1: 로컬 파일 생성
resource "local_file" "hello" {
  filename = "${path.module}/hello.txt"
  content  = "Hello, Terraform + MinIO!"
}

# 리소스 2: 로컬 파일 생성
resource "local_file" "config" {
  filename = "${path.module}/config.txt"
  content  = "generated_at = ${timestamp()}"
}
