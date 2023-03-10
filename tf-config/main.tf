terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "acn-brandon"
    workspaces {
      name = "sentinel-test-ws"
    }
  }
  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "petname" {
  length    = 4
  separator = "-"
}

resource "aws_s3_bucket" "dev" {
  bucket = "sentinel-ws-${random_pet.petname.id}"
  force_destroy = true

  tags = {
    department = "test",
    environment = "dev"
  }

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
                "arn:aws:s3:::sentinel-ws-${random_pet.petname.id}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket_acl" "dev" {
  bucket = aws_s3_bucket.dev.id
  acl    = "private"
}
