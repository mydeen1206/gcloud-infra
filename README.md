# google-cloud-terraform

Intialize gcloud CLI in local Terminal
# Initialize gcloud CLI
./google-cloud-sdk/bin/gcloud init

# List accounts whose credentials are stored on the local system:
gcloud auth list

# List the properties in your active gcloud CLI configuration
gcloud config list

# View information about your gcloud CLI installation and the active configuration
gcloud info

# gcloud config Configurations Commands (For Reference)
gcloud config list
gcloud config configurations list
gcloud config configurations activate
gcloud config configurations create
gcloud config configurations delete
gcloud config configurations describe
gcloud config configurations rename

# Configure GCP Credentials (ADC: Application Default Credentials)
# IMPORTANT: MANDATORY FOR TERRAFORM COMMANDS TO WORK WITH GCP FROM OUR LOCAL TERMINAL
gcloud auth application-default login