generate_hcl "_terramate_generated_backend.tf" {
  content {
    terraform {
      backend "gcs" {
        bucket = global.terraform.backend.gcs.bucket
        prefix = "terraform/stacks/by-id/${terramate.stack.id}/terraform.tfstate"
      }
    }
  }
}