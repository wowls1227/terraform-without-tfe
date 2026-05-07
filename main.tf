terraform {
 required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    sql = {
      source  = "paultyng/sql"  # hashicorp/sql 아님
      version = "~> 0.5"
    }
  }
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

// provider
provider "sql" {
  url = "postgres://terraform:${var.db_password}@postgresql.postgresql.svc.cluster.local:5432/tfvars?sslmode=disable"
}

provider "aws" {
  region = "ap-northeast-2"
  access_key = var.access_key
  secret_key = var.secret_key
}


// variable
variable "access_key" {}
variable "secret_key" {}
variable "db_password" {}


// data
data "sql_query" "ec2_instances" {
  query = "SELECT name, instance_type, ami, env FROM ec2_instances"
}

// local
locals {
  # 조회 결과를 for_each에 쓸 수 있게 map으로 변환
  # result 형태: [{ name=web-server, instance_type=t3.micro, ... }, ...]
  ec2_instances = {
    for row in data.sql_query.ec2_instances.result :
    row.name => row
  }
}


// resource
resource "aws_instance" "this" {
  for_each = local.ec2_instances

  ami           = each.value.ami
  instance_type = each.value.instance_type

  tags = {
    Name = each.key
    Env  = each.value.env
  }
}

// null resource
resource "terraform_data" "ls_al" {
  triggers_replace = timestamp()

  provisioner "local-exec" {
    command = "ls -al"
  }
}
