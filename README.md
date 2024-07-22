# SRE Kata Task
#### Andrew Rich | <andrew.rich@gmail.com> | [LinkedIn](https://www.linkedin.com/in/andrewrich/)

This document provides step-by-step instructions to prepare your Mac, clone the repository, and deploy the application using Terraform.

## Prerequisites

- Homebrew (package manager for macOS)
- GitHub account with access to the private repository

## Step 1: Install Homebrew

[Homebrew](https://brew.sh/) is a package manager for macOS. If you don't have it installed, open your Terminal and run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Step 2: Install AWS CLI

The AWS CLI tool will allow you to interact with AWS services from the command line.

1. Install AWS CLI using Homebrew:

```bash
brew install awscli
```

2. Configure AWS CLI with your credentials:

```bash
aws configure
```

You will be prompted to enter your AWS Access Key ID, Secret Access Key, Default region name, and Default output format. You should have received the necessary credentials from your team.

3. Confirm AWS CLI is configured properly:

```bash
aws sts get-caller-identity
```

## Step 3: Install Terraform

Terraform is used for provisioning and managing your infrastructure.

1. Install Terraform using Homebrew:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

2. Verify the installation:

```bash
terraform -version
```

## Step 4: Clone the Private GitHub Repository

1. Ensure you have Git installed:

```bash
brew install git
```

2. Clone the repository using SSH (recommended) or HTTPS. Replace `YOUR-REPO-URL` with your actual repository URL:

```bash
git clone git@github.com:YOUR-USERNAME/YOUR-REPO-NAME.git
```

Or using HTTPS:

```bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git
```

## Step 5: Deploy the Application

1. Navigate to the cloned repository directory:

```bash
cd YOUR-REPO-NAME
```

2. Initialize Terraform:

```bash
terraform init
```

3. Apply the Terraform plan to deploy the infrastructure:

```bash
terraform apply
```

4. Confirm the action when prompted by typing `yes`.

5. Terraform will output an ALB DNS name. Copy and paste that into your browser to see the sample application in operation.

```bash
alb_dns_name = "ar-sre-kata-alb-RESOURCE_ID.us-east-2.elb.amazonaws.com"
```

## Step 6: Destroy the Infrastructure (Optional)

If you need to destroy the deployed infrastructure, run:

```bash
terraform destroy
```

Confirm the action when prompted by typing `yes`.

Your AWS IAM account may not have necessary permissions to delete resources. If this happens, you can delete Terraform's local state representation of these resources.

```bash
terraform state list | grep SEARCH_TERM
terraform state rm RESOURCE1 RESOURCE2 ... RESOURCEn
```

---

You have now successfully prepared your Mac, cloned the repository, and deployed the application using Terraform. If you encounter any issues or need further assistance, please reach out to the support team.
