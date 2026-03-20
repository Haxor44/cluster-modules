# Clustered Server

Deploying a Highly Available Web App on AWS Using Terraform.

## Overview

This project provisions a highly available, auto-scaling web application infrastructure on AWS using Terraform. Traffic is distributed across multiple EC2 instances via an Application Load Balancer, ensuring resilience and fault tolerance.

## Architecture

![Architecture Diagram](animated_architecture_clean.gif)

The architecture consists of the following components:

- **Application Load Balancer (ALB)** — Receives incoming HTTP traffic on port 80 and distributes it across healthy instances in the target group.
- **Auto Scaling Group (ASG)** — Maintains a fleet of EC2 instances (min: 2, max: 5) spread across multiple availability zones in the default VPC, automatically scaling based on demand.
- **Launch Template** — Defines the instance configuration including AMI (Ubuntu 22.04), instance type, security groups, and a user data script that starts a simple HTTP server on port 8080.
- **Target Group** — Registers instances from the ASG and performs health checks to ensure only healthy instances receive traffic.
- **Security Groups** — Two security groups control access:
  - `alb-sg` — Allows inbound HTTP (port 80) to the ALB and outbound traffic to the instances.
  - `web-sg` — Allows inbound traffic on port 8080 from the ALB to the web servers.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- An AWS account with appropriate permissions
- AWS credentials configured (`~/.aws/credentials` or environment variables)

## Usage

```bash
# Initialize Terraform
terraform init

# Preview the infrastructure changes
terraform plan

# Deploy the infrastructure
terraform apply

# Destroy the infrastructure when done
terraform destroy
```

## Configuration

All configurable values are defined in `variables.tf`. Key variables include:

- `variable_region` — AWS region (default: `us-east-2`)
- `variable_instance_type` — EC2 instance type (default: `t2.micro`)
- `variable_server_port` — Web server port (default: `8080`)
- `variable_min_size` / `variable_max_size` — ASG scaling bounds (default: 2–5)

## Outputs

- `alb_dns_name` — The DNS name of the load balancer to access the application.
