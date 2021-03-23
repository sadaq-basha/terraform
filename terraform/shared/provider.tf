terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.11"
  region  = "ap-northeast-1"

  profile = "ls"
}