# SRE Kata Task
#### Andrew Rich | <andrew.rich@gmail.com> | [LinkedIn](https://www.linkedin.com/in/andrewrich/)

This document provides step-by-step instructions to prepare your Mac, clone the repository, and deploy the application using Terraform.

## Introduction
This SRE Kata Task demonstrates the implementation of a containerized web application and a serverless function using AWS services. The project showcases skills in infrastructure as code (IaC) using Terraform, containerization with ECS, and serverless computing with Lambda.

## Prerequisites

- Homebrew (package manager for macOS)
- GitHub account with access to the private repository

## Software Versions

This project primarily relies on default versions provided by Terraform and AWS services to ensure compatibility and ease of maintenance. We use Terraform 1.0 or later, which automatically selects appropriate provider versions. For AWS services, we allow the use of default, up-to-date versions managed by AWS. Specific version notes:

- Terraform: 1.0 or later (latest version recommended)
- AWS Provider: Latest version compatible with used Terraform version
- ECS: Latest available Amazon ECS-Optimized Amazon Linux 2 AMI
- Lambda Runtime: Ruby 3.3
- Container Images:
  - Web Application: `beamdental/sre-kata-app` (latest)
  - Redis: `redis:latest`

While we don't pin most versions explicitly, this approach allows for easier updates and maintenance. In a production environment, you might consider specifying exact versions for stricter control and reproducibility.

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

[Terraform](https://www.terraform.io/) is used for provisioning and managing your infrastructure.

1. Install Terraform using Homebrew:

	```bash
	brew tap hashicorp/tap
	brew install hashicorp/tap/terraform
	```

2. Verify the installation:

	```bash
	terraform -version
	```

## Step 4: Clone the private GitHub repository

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

	After cloning the repository, you'll find the following structure:
	
	```
	ar-sre-kata/
	├── modules/
	│   ├── container_service/
	│   ├── networking/
	│   └── serverless/
	├── main.tf
	├── variables.tf
	├── outputs.tf
	├── providers.tf
	└── README.md
	```
	
	- `modules/`: Contains Terraform modules for different components of the infrastructure.
	- `main.tf`: The main Terraform configuration file that calls the modules.
	- `variables.tf`: Defines input variables for the Terraform configuration.
	- `outputs.tf`: Specifies the outputs from the Terraform apply process.
	- `providers.tf`: Configures the required providers for the project.

## Step 5: Deploy and test the applications

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

### Task-1: Container service with Redis and Web application

As part of Task-1, we've implemented a container service using AWS ECS (Elastic Container Service). Here's what we've done:

1. Created an ECS cluster to manage our containers.
2. Deployed two containers:

	a. A Redis instance for data storage.
	
	b. A web application that depends on Redis (using the `beamdental/sre-kata-app` image).

3. Set up an Application Load Balancer (ALB) to route traffic to the web application.
4. Configured the necessary networking components (VPC, subnets, security groups).
5. Implemented logging to CloudWatch for both containers.

To test the deployed application:

1. After the Terraform apply completes, note the ALB DNS name from the output:

	```bash
	alb_dns_name = "ar-sre-kata-alb-RESOURCE_ID.us-east-2.elb.amazonaws.com"
	```

2. Open a web browser and navigate to the ALB DNS name. Click through the insecure warning since we have not implemented HTTPS for this demonstration.

	Note: The ALB will display a 503 error until services have initialized. You can watch the initialization process in the `Tasks` view under the ECS service.

To view the ECS service details and logs:

1. Go to the AWS Console and navigate to the ECS service.
2. Find and select the `ar-sre-kata-cluster`.
3. Click on the `ar-sre-kata-app-and-redis-service` to view details about the running tasks.
4. To view logs:

	a. Click on a running task.
	
	b. In the "Logs" tab, you can view logs for both the web application and Redis containers.

	You can also view the logs in CloudWatch:

	1. In the AWS Console, go to CloudWatch.
	2. Navigate to "Log groups" in the left sidebar.
	3. Find and click on the "/ecs/ar-sre-kata-app" and "/ecs/ar-sre-kata-redis" log groups.

### Task-3: Serverless Function for Brewery Data

As part of Task-3, we've implemented a serverless function that fetches brewery data from the [OpenBreweryDB](https://www.openbrewerydb.org) API. Here's what we've done:

1. Created a Lambda function (`AR-BreweryParser`) that fetches brewery data for Columbus, Ohio (39°57'28.7"N, 82°59'50.5"W).
2. Implemented logging to CloudWatch, which outputs the brewery data in JSON format.
3. Created a test runner (`AR-TestRunner`) to verify the functionality.
4. Integrated unit tests that run during the Terraform apply process.

To test the `AR-BreweryParser` function:

1. Go to the AWS Console and navigate to the Lambda service.
2. Find and select the `AR-BreweryParser` function.
3. Click on the "Test" tab and create a new test event with an empty JSON object `{}`.
4. Click "Test" to run the function.
5. Check the execution results and CloudWatch logs to see the brewery data output.

To view the CloudWatch logs:

1. In the AWS Console, go to CloudWatch.
2. Navigate to "Log groups" in the left sidebar.
3. Find and click on the `/aws/lambda/AR-BreweryParser` log group.
4. Click on the latest log stream to view the most recent function execution logs.

The `AR-TestRunner` function can be tested similarly through the AWS Console if needed. Additional IAM permissions would be required to configure EventBridge to automatically run the unit tests.

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

## Secure Password Management (Hypothetical)

While this project does not utilize any passwords, in a real-world scenario, secure password management is crucial. Here's how we would approach providing passwords securely:

1. Use AWS Secrets Manager or AWS Systems Manager Parameter Store to securely store sensitive information like passwords.
2. In your Terraform configuration, you would reference these secrets using data sources. For example:

   ```hcl
   data "aws_secretsmanager_secret_version" "db_password" {
     secret_id = "my-db-password"
   }
   ```

3. When needed in your resources, reference the secret like this:

   ```hcl
   resource "aws_db_instance" "example" {
     # ... other configuration ...
     password = data.aws_secretsmanager_secret_version.db_password.secret_string
   }
   ```

4. Ensure that your IAM roles have the minimum necessary permissions to access these secrets.
5. Use Terraform's sensitive output feature to prevent accidental exposure of sensitive data in logs:

   ```hcl
   output "db_password" {
     value     = data.aws_secretsmanager_secret_version.db_password.secret_string
     sensitive = true
   }
   ```

6. For local development, consider using tools like `git-crypt` or `SOPS` to encrypt sensitive files in your repository.

Remember, never hard-code passwords or other sensitive information directly in your Terraform configurations or commit them to version control.

## Troubleshooting

If you encounter issues during deployment or testing, try the following:

1. Get the current Terraform state and outputs.

	```bash
	terraform refresh && terraform output
	```

1. Ensure your AWS credentials are correctly configured and have the necessary permissions.
2. Check the CloudWatch logs for each service to identify any runtime errors.
3. If a Terraform apply fails, run `terraform plan` to see what changes are pending and why they might be failing.
4. For networking issues, verify that security groups and VPC settings are correctly configured.

If problems persist, please refer to the AWS documentation or reach out to the contact listed at the top of this document.

## Cleaning Up

To avoid unnecessary AWS charges, remember to destroy your infrastructure when you're done testing:

1. Run `terraform destroy` and confirm when prompted.
2. Double-check the AWS Console to ensure all resources have been properly removed.
3. Monitor your AWS billing dashboard for any unexpected charges.

---

## Conclusion
You have now successfully prepared your Mac, cloned the repository, and deployed the application using Terraform. If you encounter any issues or need further assistance, please reach out to the contact listed at the top of this document.
