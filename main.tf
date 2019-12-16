//this doesn't seem to make sense but its the best way to trivially supply either an org or a folder as a parent
resource "google_folder" "folder" {
  display_name = var.name
  parent       = var.parent
}

resource "random_string" "project_suffix" {
  length  = var.suffix_length
  special = false
  lower   = false
  upper   = false

}

resource "google_project" "project" {
  name            = "${var.name}-${random_string.project_suffix.result}"
  project_id      = "${var.name}-${random_string.project_suffix.result}"
  folder_id       = google_folder.folder.name
  billing_account = var.billing_id
  depends_on      = ["google_folder.folder"]
}

resource "google_project_service" "services" {
  for_each           = var.services
  service            = each.key
  project            = google_project.project.id
  disable_on_destroy = false
  depends_on         = ["google_project.project"]
}

resource "google_service_account" "ci_account" {
  account_id   = var.service_account_name
  display_name = var.service_account_name
  project      = google_project.project.id
  depends_on   = ["google_project.project"]
}

resource "google_service_account_key" "ci_account" {
  service_account_id = google_service_account.ci_account.name
}

resource "google_folder_iam_policy" "iam_policy" {
  folder      = google_folder.folder.name
  policy_data = data.google_iam_policy.folder_policy.policy_data
}

locals {
  service_accounts = [
    "serviceAccount:${google_service_account.ci_account.email}",
    "serviceAccount:${google_project.project.number}@cloudbuild.gserviceaccount.com",
  ]
}


//i may be being too explicit here as i'm sure some roles contain others, but i don't think it's an issue
data "google_iam_policy" "folder_policy" {
  binding {
    role = "roles/owner"

    members = toset(concat(var.owners, local.service_accounts))
  }
  binding {
    role = "roles/resourcemanager.projectCreator"

    members = toset(concat(var.owners, local.service_accounts))
  }
  binding {
    role = "roles/storage.admin"

    members = toset(concat(var.owners, local.service_accounts)) //may need to add all users here
  }
  binding {
    role = "roles/iam.securityAdmin"

    members = toset(concat(var.owners, local.service_accounts))
  }
  binding {
    role = "roles/viewer"

    members = toset(concat(var.owners, var.developers, var.viewers))
  }
  binding {
    role = "roles/container.developer"

    members = toset(concat(var.owners, var.developers))
  }
  binding {
    role = "roles/browser"

    members = toset(concat(var.owners, var.developers, var.viewers))
  }
  binding {
    role    = "roles/cloudbuild.builds.viewer"
    members = toset(concat(var.owners, var.developers, var.viewers))
  }
  binding {
    role    = "roles/cloudbuild.builds.builder"
    members = toset(concat(var.owners, var.developers, var.viewers))
  }
}

resource "random_uuid" "tfstate-bucket-name" {}

resource "google_storage_bucket" "terraform_state" {
  name     = "${random_uuid.tfstate-bucket-name.result}"
  location = var.region
  project  = google_project.project.name
}

resource "google_storage_bucket_iam_binding" "terraform_state_binding" {
  bucket = "${google_storage_bucket.terraform_state.name}"
  role   = "roles/storage.objectAdmin"

  members = local.service_accounts
}

resource "google_storage_bucket" "cloudbuild_bucket" {
  name    = "${google_project.project.name}_cloudbuild"
  project = google_project.project.name
}

resource "google_storage_bucket_iam_binding" "cloudbuild_bucket_admin_binding" {
  bucket = "${google_storage_bucket.cloudbuild_bucket.name}"
  role   = "roles/storage.objectAdmin"

  members = local.service_accounts
}

resource "google_storage_bucket_iam_binding" "cloudbuild_bucket_viewer_binding" {
  bucket = "${google_storage_bucket.cloudbuild_bucket.name}"
  role   = "roles/storage.objectViewer"

  members = concat(var.owners, var.developers, var.viewers, local.service_accounts)
}
