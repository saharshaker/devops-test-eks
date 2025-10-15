# Gandalf Web App on EKS with Prometheus

## Overview

This repo deploys a lightweight Flask web app to **AWS EKS** using **Terraform**.
The app exposes:

* `GET /gandalf` → Gandalf’s picture
* `GET /colombo` → current time in Colombo (Sri Lanka)
* `GET /metrics` → Prometheus metrics (basic auth)

Custom counters:

* `gandalf_requests_total` — total hits to `/gandalf`
* `colombo_requests_total` — total hits to `/colombo`

Traffic is served on **port 80** behind a **Network Load Balancer (NLB)** with **static IPs**.

---

## Architecture

* **Terraform Backend (S3)**
  Remote state stored in a versioned, AES-256 encrypted S3 bucket (e.g. `adcash-terraform-state-bucket`).
  Backend config: `terraform/environments/dev/backend.hcl`
  State key: `eks/dev/terraform.tfstate` (environment-based layout)

* **VPC & EKS**

  * Two **public** and two **private** subnets
  * One **node group** in private subnets (dev)
  * **NLB** with **two static IPs** (Elastic IPs)
  * Only **port 80** exposed

* **App & Metrics**

  * Flask app with `/gandalf`, `/colombo`, `/metrics`
  * Built-in exporter; no sidecar
  * `/metrics` protected via basic auth (`prom` / `1234` in dev)

* **Prometheus (external)**

  * A dedicated **EC2** for Prometheus is provisioned by Terraform
  * Installation is done by a rendered shell template: `prometheus-installation.sh.tftpl`

> For production-grade secret handling, AWS Secrets Manager or HashiCorp Vault could be used. This exercise keeps it basic.

---

## Requirements

* **Terraform**
* **AWS CLI**
* **kubectl**

AWS CLI must have permissions for S3, EKS, EC2, IAM, etc.

---

## Repository Layout

* `terraform/environments/dev/` — environment-based Terraform configuration (backend, variables)
* `terraform/` — EKS/VPC modules & related IaC
* `app/` — Flask app and Kubernetes manifests for the application (`deployment.yml`, `service.yml`)

> **Note:** Kubernetes manifests are under `app/`.

---

## Bootstrap

### 1) Create and secure the S3 bucket for Terraform state

```bash
aws s3api create-bucket \
  --bucket adcash-terraform-state-bucket \
  --region eu-central-1 \
  --create-bucket-configuration LocationConstraint=eu-central-1

aws s3api put-bucket-versioning \
  --bucket adcash-terraform-state-bucket \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket adcash-terraform-state-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm": "AES256" }
    }]
  }'
```

### 2) Create an SSH key pair for the Prometheus VM (required)

Create an EC2 key pair in your AWS account (or import your public key).
Put the **key name** in your **dev variables** file:

* **Edit:** `terraform/environments/dev/terraform.tfvars`
  Add something like:

  ```hcl
  prometheus_ec2_key_name = "your-ec2-keypair-name"
  ```

### 3) Set basic auth credentials (dev)

If you keep the simple approach, set them via vars (or env) as used in your Terraform/user-data or Prometheus config:

```hcl
prometheus_basic_auth_user = "prom"
prometheus_basic_auth_pass = "1234"
```

---

## Deploy (dev)

```bash
terraform init -backend-config="key=eks/dev/terraform.tfstate"

terraform plan  -var-file="environments/dev/terraform.tfvars"

terraform apply -var-file="environments/dev/terraform.tfvars"
```

Update kubeconfig:

```bash
aws eks update-kubeconfig --region eu-central-1 --name adcash-dev-cluster
```

Apply manifests (from the `app/` directory):

```bash
kubectl apply -f app/deployment.yml
kubectl apply -f app/service.yml
```

> **Important:** The **public subnet IDs** and **EIP allocation IDs** that Terraform outputs must be written into `app/service.yml` so the NLB can attach the correct subnets and static IPs. (For a cleaner setup, template these via Terraform outputs or Helm.)

---

## Access

After the service is up behind the NLB:

* `http://<static-ip>/gandalf`
* `http://<static-ip>/colombo`
* `http://<static-ip>/metrics` (basic auth)

Default dev metrics credentials:

* user: `prom`
* pass: `1234`

---
Prometheus Scraping Approaches (trade-offs)

Several options were considered:

External VM (chosen here):
A Prometheus EC2 VM scrapes the app’s /metrics over HTTP with basic auth.
✔ Simple separation of concerns; independent lifecycle; easy to harden.

In-cluster Prometheus:
Run Prometheus inside EKS (via Helm/Operator), discover services via service accounts/RBAC and scrape internally.
✔ Native service discovery; good for larger setups.
✖ Not aligned with the “separate VM” requirement of this exercise.

Direct pull with SA/RBAC from outside:
Grant scoped credentials to Prometheus so it queries the cluster API/service endpoints directly.
✔ No extra routing; secure with least privilege.
✖ More setup (IAM, SA, RBAC), and tighter coupling to cluster auth.

This stack opts for #1 to keep the surface area small and setup straightforward for a dev environment.

---
## Notes & Recommendations

.tfvars files should not be committed to source control. Store sensitive values (e.g., prometheus_key_name, basic-auth credentials, EIP/Subnet IDs if treated as secrets, etc.) in GitHub Secrets (or your CI/CD secret store) and inject them at runtime.

For this exercise: the dev .tfvars is committed for grading/demo purposes.

Ensure the **EKS cluster version** matches the **node group AMI**.

---

## Cleanup

```bash
terraform destroy -var-file="environments/dev/terraform.tfvars"
```

---
