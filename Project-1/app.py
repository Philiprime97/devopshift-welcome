from jinja2 import Environment, FileSystemLoader
from python_terraform import Terraform
import boto3, json

# --- Ask user for input ---
def get_user_input():
    region = input("Region (only us-east-2): ").strip()
    if region != "us-east-2":
        print("Using default: us-east-1")
        region = "us-east-2"

    ami = input("AMI (Ubuntu Server 24.04 LTS AMI / Amazon Linux 2023 kernel-6.1 AMI): ").strip()
    ami_map = {
        "Ubuntu Server 24.04 LTS AMI ": "ami-042b4708b1d05f512",
        "Amazon Linux 2023 kernel-6.1 AMI": "ami-09278528675a8d54e"
    }
    ami_id = ami_map.get(ami, ami_map["ubuntu"])

    inst_type = input("Instance Type (t3.small/t3.medium): ").strip()
    if inst_type not in ["t3.small", "t3.medium"]:
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

# --- Render main.tf from the template ---
def render_template(variables):
    env = Environment(loader=FileSystemLoader('.'))
    template = env.get_template('main.tf.j2')
    rendered = template.render(variables)
    with open("app.py", "w") as f:
        f.write(rendered)

# --- Run terraform ---
def run_terraform():
    tf = Terraform(working_dir=".")
    tf.init()
    tf.plan()
    tf.apply(skip_plan=True)
    return tf.output()

# --- Validate AWS resources ---
def validate_with_boto(instance_id, alb_name):
    ec2 = boto3.client("ec2", region_name="us-east-2")
    elb = boto3.client("elbv2", region_name="us-east-2")

    inst = ec2.describe_instances(InstanceIds=[instance_id])
    inst_data = inst["Reservations"][0]["Instances"][0]
    state = inst_data["State"]["Name"]
    ip = inst_data.get("PublicIpAddress")

    lb = elb.describe_load_balancers(Names=[alb_name])
    lb_dns = lb["LoadBalancers"][0]["DNSName"]

    return {
        "instance_id": instance_id,
        "instance_state": state,
        "public_ip": ip,
        "load_balancer_dns": lb_dns
    }

# --- MAIN FUNCTION ---
def main():
    config = get_user_input()
    render_template(config)
    run_terraform()
    
    with open("aws_validation.json", "w") as f:
        json.dump(result, f, indent=2)
    print("Deployment successful. Results saved to aws_validation.json")

if __name__ == "__main__":
    main()