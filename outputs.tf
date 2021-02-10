output "project_name" {
  value = google_project.project.name
}

output "project_id" {
  value = google_project.project.id
}

output "terraform_state_bucket_name" {
  value = google_storage_bucket.terraform_state.name
}

output "service_account_email" {
  value = google_service_account.ci_account.email
}
