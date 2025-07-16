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
        
        print("Running: terraform plan...")
        return_code, stdout, stderr = tf.plan()
        if return_code != 0:
            raise Exception(f"Terraform plan failed: {stderr}")
        
        print("Running: terraform apply...")
        return_code, stdout, stderr = tf.apply(skip_plan=True)
        if return_code != 0:
            raise Exception(f"Terraform apply failed: {stderr}")
        
        return tf.output()
    except Exception as e:
        print(f"Terraform error: {e}")
        raise


# --- MAIN ---
def main():
    try:
        variables = get_user_input()
        render_template(variables)
        
        output = run_terraform()
        
        print("Waiting 240 seconds for AWS resources to fully initialize...")
        time.sleep(240)
        print(output)
        
        with open("terraform_output.json", "w") as f:
            json.dump(output, f, indent=2)

        print("Deployment successful. Output saved to terraform_output.json")
        

    except Exception as e:
        print(f"Script failed: {e}")

if __name__ == "__main__":
    main()