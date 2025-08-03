#!/bin/bash

# === CONFIGURATION ===
PROJECT_ID="terraform-467505"
GITHUB_REPO="mydeen1206/personal-blog-website"
GKE_CLUSTER_NAME="dev.devops-gke-cluster"
REGION="us-central1"
POOL_ID="github-pool"
PROVIDER_ID="github-provider"
SERVICE_ACCOUNT_NAME="github-deployer"

# === DERIVED VALUES ===
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

echo "Using project ID: $PROJECT_ID"
echo "Project number: $PROJECT_NUMBER"
echo "GitHub repo: $GITHUB_REPO"
echo "Service Account: $SERVICE_ACCOUNT_EMAIL"

# 1. Create Workload Identity Pool
echo "Creating Workload Identity Pool..."
gcloud iam workload-identity-pools create "$POOL_ID" \
  --project="$PROJECT_ID" \
  --location="global" \
  --display-name="GitHub Actions Pool"

# 2. Create Workload Identity Provider
echo "Creating OIDC Provider..."
gcloud iam workload-identity-pools providers create-oidc "$PROVIDER_ID" \
  --project="$PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="$POOL_ID" \
  --display-name="GitHub Actions Provider" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository"

# 3. Create Service Account
echo "Creating service account..."
gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
  --project="$PROJECT_ID" \
  --display-name="GitHub OIDC Deployer"

# 4. Allow GitHub repo to impersonate the service account
echo "Binding GitHub repo to impersonate SA..."
gcloud iam service-accounts add-iam-policy-binding "$SERVICE_ACCOUNT_EMAIL" \
  --project="$PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL_ID/attribute.repository/$GITHUB_REPO"

# 5. Grant service account GKE deployment permissions
echo "Granting container.admin role..."
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/container.admin"

echo "✅ Setup complete. You can now deploy to GKE from GitHub Actions using OIDC!"
