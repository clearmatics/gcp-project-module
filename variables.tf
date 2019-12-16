variable "name" {
  description = "the name of your GCP project"
  type        = "string"
}


variable "parent" {
  description = "the parent id of the object this will live under (folder or organisation)"
  type        = "string"

}

variable "billing_id" {
  description = "Your gcp billing account id"
  type        = "string"

}
// Possibly split services into core_services and additional_services (so that core services never need to be respecified)
variable "services" {
  description = "List of services to be enabled on the project"
  type        = set(string)
  default = [
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "storage-api.googleapis.com",
    "websecurityscanner.googleapis.com",
  ]
}


variable "service_account_name" {
  description = "The name of the service account. Note: full service account e-mail must be less than 63 chracters, or it breaks kubergrunt/tiller setup"
  default     = "ci-account"
}

variable "owners" {
  description = "List of Users granted full access to the project"
  type        = list(string)
  default     = []
}

variable "developers" {
  description = "List of Users with additional cloudbuild permissions"
  type        = list(string)
  default     = []
}

variable "viewers" {
  description = "List of Users with view only access"
  type        = list(string)
  default     = []
}

variable "region" {
  default = "europe-west2"
}


variable "suffix_length" {
  default = 4
}
