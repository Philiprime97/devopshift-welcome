from jinja2 import Environment, FileSystemLoader
from python_terraform import Terraform
import json
import time
import os

# --- Ask user for input ---
def get_user_input():
    region = input("Region (only us-east-2): ").strip()
    if region != "us-east-2":
        print("Only 'us-east-2' is allowed. Defaulting to us-east-2.")
        region = "us-east-2"

    ami = input("AMI (ubuntu / amazon): ").strip().lower()
    ami_map = {
        "ubuntu": "ami-0d1b5a8c13042c939",
        "amazon": "ami-09278528675a8d54e"
    }
    ami_id = ami_map.get(ami, ami_map["amazon"])

    inst_type = input("Instance Type (t3.small/t3.medium): ").strip()
    if inst_type not in ["t3.small", "t3.medium"]:
        print("Invalid instance type. Using default: t3.small")
        inst_type = "t3.small"

    alb = input("Load Balancer Name: ").strip()
    if alb == "":
        alb = "my-alb"

    return {
        "region": region,
        "ami": ami_id,
        "instance_type": inst_type,
        "load_balancer_name": alb
    }

# --- Creates main.tf from template ---
def render_template(variables):
    if not os.path.exists('main.tf.j2'):
        raise FileNotFoundError("Template file 'main.tf.j2' not found.")
    
    env = Environment(loader=FileSystemLoader('.'))
    template = env.get_template('main.tf.j2')
    rendered = template.render(variables)
    
    with open("main.tf", "w") as f:
        f.write(rendered)

# --- Run Terraform ---
def run_terraform():
    try:
        tf = Terraform(working_dir=".")
        
        print("Running: terraform init...")
        return_code, stdout, stderr = tf.init()
        if return_code != 0:
            raise Exception(f"Terraform init failed: {stderr}")
        
        # print("Running: terraform plan...")
        # return_code, stdout, stderr = tf.plan()
        # if return_code != 0:
        #     raise Exception(f"Terraform plan failed: {stderr}")
        
        print("Running: terraform apply...")
        return_code, stdout, stderr = tf.apply(skip_plan=True)
        if return_code != 0:
            raise Exception(f"Terraform apply failed: {stderr}")
        
        return tf.output()
    except Exception as e:
        print(f"Terraform error: {e}")
        raise


 # --- AWS Validation using boto3 ---   
def aws_validation(region, instance_id, alb_name):
    ec2 = boto3.client("ec2", region_name=region)
    elbv2 = boto3.client("elbv2", region_name=region)

    validation_data = {
        "instance_id": None,
        "instance_state": None,
        "public_ip": None,
        "load_balancer_dns": None
    }

    # Validate EC2 instance
    try:
        print("\nValidating EC2 instance...")
        reservations = ec2.describe_instances(InstanceIds=[instance_id])['Reservations']
        if not reservations:
            raise Exception(f"No instance found with ID {instance_id}")

        instance = reservations[0]['Instances'][0]
        state = instance['State']['Name']
        if state != "running":
            raise Exception(f"Instance {instance_id} is not running. Current state: {state}")

        public_ip = instance.get('PublicIpAddress')
        if not public_ip:
            raise Exception(f"Instance {instance_id} does not have a public IP assigned.")

        validation_data["instance_id"] = instance_id
        validation_data["instance_state"] = state
        validation_data["public_ip"] = public_ip

        print(f"Instance {instance_id} is running with public IP {public_ip}")

    except Exception as e:
        print(f"EC2 Validation Error: {e}")
        raise

    # Validate ALB
    try:
        print("\nValidating ALB...")
        lbs = elbv2.describe_load_balancers(Names=[alb_name])['LoadBalancers']
        if not lbs:
            raise Exception(f"No load balancer found with name {alb_name}")

        lb = lbs[0]
        dns_name = lb['DNSName']
        validation_data["load_balancer_dns"] = dns_name

        print(f"ALB {alb_name} exists with DNS: {dns_name}")

    except Exception as e:
        print(f"ALB Validation Error: {e}")
        raise

    # Print validation data to CLI
    print("\nAWS Validation Result:")
    print(json.dumps(validation_data, indent=2))

    # Save validation results to JSON file
    with open("aws_validation.json", "w") as f:
        json.dump(validation_data, f, indent=2)
    print("\nValidation data saved to aws_validation.json")

    return validation_data


# --- MAIN ---
def main():
    try:
        variables = get_user_input()
        render_template(variables)

        # Capture output from Terraform
        output = run_terraform()
        
        print("Waiting 240 seconds for AWS resources to fully initialize...")
        time.sleep(240)

        # Save terraform output to JSON
        with open("terraform_output.json", "w") as f:
            json.dump(output, f, indent=2)
        print("Terraform output saved to terraform_output.json")

        # Extract instance ID from Terraform output
        instance_id = output.get("web_server_philip_id", {}).get("value")
        alb_name = variables["load_balancer_name"]

        if not instance_id:
            raise Exception("Instance ID not found in Terraform output.")

        # AWS validation using boto3
        validation_result = aws_validation(variables["region"], instance_id, alb_name)

        print("\nValidation data returned from aws_validation():")
        print(json.dumps(validation_result, indent=2))

        print("\nDeployment and validation completed successfully.")

    except Exception as e:
        print(f"\nScript failed: {e}")





if __name__ == "__main__":
    main()