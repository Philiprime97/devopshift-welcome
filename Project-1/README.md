# AWS EC2 and ALB Deploy Project
This project was built as a training exercise. The goal is to deploy a single EC2 instance and an Application Load Balancer (ALB) on AWS using **Terraform** and **Python**.

# What the Project Does
- Prompts the user for input:  
  - AMI type (Ubuntu or Amazon Linux)  
  - EC2 instance type  
  - Load Balancer name  

- Generates a `main.tf` Terraform configuration file using **Jinja2** templating  
- Executes `terraform init` and `terraform apply` directly from Python  
- Uses **Boto3** to verify that:
  - The EC2 instance exists and is in a `running` state
  - The ALB exists and retrieves its DNS name  
- Saves validation results into a JSON file


# Tools & Technologies Used
- **Terraform** – for provisioning AWS infrastructure  
- **Python** – the orchestration logic  
- **Jinja2** – for generating `.tf` files dynamically  
- **Boto3** – for validating resources on AWS   
- AWS CLI – must be configured with valid credentials


# How to Run It
1.Set AWS Credentials
  - export AWS_ACCESS_KEY_ID=your_access_key
  - export AWS_SECRET_ACCESS_KEY=your_secret_key
  - export AWS_DEFAULT_REGION=us-east-2

2.Run the Deployment Script
   - python3 app.py
   
   The script will ask you for:
   -	AMI type (ubuntu/amazon)
   -	Instance type (t3.small/t3.medium)
   -	Load Balancer name

   This script will:
   -	Verify the instance is running
   -	Show the public IP
   -	Display the ALB DNS name

 # Project Files
   -	main.py - Main script to deploy EC2 and ALB
   - 	main.tf.j2 - Jinja2 template used to generate main.tf
   - 	terraform_output.json - Stores outputs results from Terraform
   - 	aws_validation.json - Stores validation result from AWS

# Output
<img width="1032" height="433" alt="Screenshot 2025-07-16 at 17 42 14" src="https://github.com/user-attachments/assets/65df0c87-2251-45c8-94a1-f7819385aae7" />

