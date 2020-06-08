terraform {
  backend "s3" {
    bucket = "stage-terraform-state-production"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
