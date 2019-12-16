# Clearmatics GCP Project Module

This is a module to instanciate to get the following:

- a new gcp project in its own folder (probably need to tweak this)
- a service account able to run terraform within the project
- a terraform state bucket within the project
- a cloudbuild bucket and the service enabled (repo linking needs to happen manually)

This might be instanciated as follows (example based on internal project)

```
module "sample_project" {
  source       = git@github.com:clearmatics/gcp-project-module.git
  name         = "sample"
  parent       = google_folder.product.name
  billing_id   = var.GCP_BILLING_ID
  owners       = ["group:group@${var.ORGANIZATION_DOMAIN}"]
  developers   = ["domain:${var.ORGANIZATION_DOMAIN}"]
  viewers      = ["domain:${var.ORGANIZATION_DOMAIN}"]
}
```
