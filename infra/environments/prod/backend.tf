terraform {
  backend "s3" {
    bucket         = "s3-backend-state-project"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    use_lockfile = true 
    encrypt        = true
  }
} 

