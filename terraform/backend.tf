terraform {
  backend "s3" {
    bucket       = "adcash-terraform-state-bucket"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}