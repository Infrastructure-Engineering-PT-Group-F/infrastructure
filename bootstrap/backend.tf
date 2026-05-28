terraform {
  backend "gcs" {
    bucket = "dark-diagram-496907-k8-tfstate"
    prefix = "bootstrap"
  }
}
