terraform {
  backend "s3" {
    bucket = "terraform-state" # Name of the S3 bucket
    endpoints = {
      s3 = "http://minio.minio.svc.cluster.local:9000" # Minio endpoint
    }
    key = "tfstate-local" # Name of the tfstate file


    region                      = "main"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}

variable "access_key" {}
variable "secret_key" {}

provider "local" {}
provider "aws" {
  region = "ap-northeast-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_instance" "example" {
  ami           = "ami-0c9c942bd7bf113a2"  # Amazon Linux 2023 (서울)
  instance_type = "t3.micro"

  tags = {
    Name = "kjj-example-instance"
  }
}


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

# null resource
resource "terraform_data" "ls_al" {
  triggers_replace = timestamp()

  provisioner "local-exec" {
    command = "ls -al"
  }
}
