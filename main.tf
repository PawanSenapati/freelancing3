provider "google" {
  project = "gcp-devops-376307"
  region  = "us-central1"
  zone    = "us-central1-a"
}

variable "image_tag" {
  type = string
}

terraform {
 backend "gcs" {
   bucket  = "freelancing3"
   prefix  = "/"
 }
}
data "terraform_remote_state" "foo" {
  backend = "gcs"
  config = {
    bucket  = "freelancing3"
    prefix  = "prod"
  }
}

resource "google_cloud_run_service" "app_service" {
  name     = "freelancing3-test"
  location = "us-central1"
  
  template {
    spec {
      containers {
        image = "gcr.io/gcp-devops-376307/freelancing3:${var.image_tag}"
      }
    }
  }
}
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.app_service.location
  project = "gcp-devops-376307"
  service     = google_cloud_run_service.app_service.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
