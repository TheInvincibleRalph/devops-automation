/*
terraform {
  backend "s3" {
    bucket         = "s3-backend-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile = true
    encrypt        = true
  }
} 
*/
