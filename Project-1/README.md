# AWS EC2 and ALB Deploy Project

This project was built as a **training exercise**. The goal is to deploy a single EC2 instance and an Application Load Balancer (ALB) on AWS using **Terraform** and **Python**.

---

## 🛠️ What the Project Does

- Prompts the user for input:
  - AMI type (Ubuntu or Amazon Linux)
  - EC2 instance type
  - Load Balancer name
  - Region and availability zone

- Generates a `main.tf` Terraform configuration file using **Jinja2**

- Executes `terraform init` and `terraform apply` from Python

- Uses **Boto3** to validate:
  - The EC2 instance exists and is in the `running` state
  - The ALB exists and retrieves its DNS name

- Saves validation results into a JSON file

---

## 🧰 Tools & Technologies Used

- **Terraform** – for provisioning AWS infrastructure  
- **Python** – orchestration and logic  
- **Jinja2** – to generate `.tf` files dynamically  
- **Boto3** – to validate resources on AWS  
- **AWS CLI** – must be configured with valid credentials

---

## ⚙️ Prerequisites

- Python 3.7+
- AWS CLI configured with appropriate credentials
- Terraform installed and in PATH
- Virtual environment (recommended)

### Install Required Python Packages

```bash
pip install boto3 jinja2 python-terraform
```

---

## 🚀 Quick Start

### 1. Environment Setup

```bash
# Clone the repository
git clone <repository-url>
cd Project-1

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate     # Linux/Mac
# or
source venv/Scripts/activate  # Windows Git Bash
```

### 2. Run the Deployment

```bash
python app.py
```

You will be prompted to enter:
- AMI ID
- Instance type
- Availability zone
- Load Balancer name
- AWS region

### 3. Deploy Infrastructure

```bash
terraform init
terraform apply
```

### 4. Save Outputs

```bash
terraform output -json > terraform_output.json
```

### 5. Validate Deployment

```bash
python validate_aws.py
```

Check `aws_validation.json` for confirmation and results.

### 6. Cleanup (Optional)

```bash
terraform destroy
```

---

## 🧪 How to Run It Manually

### 1. Set AWS Credentials

```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-2
```

### 2. Run the Script

```bash
python3 app.py
```

The script will:
- Prompt for:
  - AMI type (ubuntu/amazon)
  - Instance type (t3.small/t3.medium)
  - Load Balancer name
- Verify the instance is running
- Show the public IP
- Display the ALB DNS name

---

## 📁 Project Files

| File | Description |
|------|-------------|
| `main.py` | Main script to deploy EC2 and ALB |
| `main.tf.j2` | Jinja2 template used to generate `main.tf` |
| `terraform_output.json` | Stores output results from Terraform |
| `aws_validation.json` | Stores validation result from AWS |

---

## 📸 Output Example

<img width="1032" height="433" alt="Screenshot 2025-07-16 at 17 42 14" src="https://github.com/user-attachments/assets/d873edac-d106-41a3-ac64-340879bb172b" />

