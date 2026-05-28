# bootstrap

One-time **seed** module, run by a human operator with their own credentials (ADC).
It creates the least-privilege `terraform-automation` service account that the root
module impersonates for all later provisioning.

## Run

```sh
gcloud auth application-default login
nano terraform.tfvars   # set project_id + operator_members
terraform init
terraform plan -out tfplan
terraform apply tfplan
```

Verify and capture the SA for the root provider:

```sh
terraform output -raw terraform_service_account_email
gcloud auth print-access-token \
  --impersonate-service-account="$(terraform output -raw terraform_service_account_email)"
```