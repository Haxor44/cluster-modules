# webserver-cluster

## Overview

This module provisions a highly available, auto-scaling web server cluster on AWS. It creates an Application Load Balancer (ALB) that accepts HTTP traffic on port 80 and distributes it across a fleet of Ubuntu 22.04 EC2 instances managed by an Auto Scaling Group (ASG); each instance runs a minimal `busybox` HTTP server on port 8080. The module also creates the required Launch Template, Target Group with HTTP health checks, and two Security Groups — one for the ALB and one for the EC2 instances — all within the account's default VPC.

## Architecture

![Infrastructure as Code with Terraform Modules](terraform_modules_versioning_1774613610037.png)

## Usage

Minimum required inputs:

```hcl
module "webserver_cluster" {
  source = "github.com/haxor44/cluster-modules//modules/services/webserver-cluster?ref=v0.0.2"

  cluster_name = "webservers-dev"
}

output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}
```

## Input Variables

### Required

| Name | Type | Description |
|------|------|-------------|
| `cluster_name` | `string` | The name to use for all cluster resources |

### Optional

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `variable_region` | `string` | `"us-east-2"` | AWS region where the cluster is deployed |
| `variable_instance_type` | `string` | `"t2.micro"` | EC2 instance type for the web servers |
| `variable_min_size` | `number` | `2` | Minimum number of instances in the ASG |
| `variable_max_size` | `number` | `5` | Maximum number of instances in the ASG |
| `variable_server_port` | `number` | `8080` | Port the web server process listens on inside each instance |
| `variable_launch_template_name` | `string` | `"web-launch"` | Name for the EC2 Launch Template |
| `variable_asg_lt_version` | `string` | `"$Latest"` | Launch Template version used by the ASG |
| `variable_asg_health_check_type` | `string` | `"ELB"` | Health check type for the ASG (`EC2` or `ELB`) |
| `variable_lb_name` | `string` | `"web-lb"` | Name of the Application Load Balancer |
| `variable_lb_type` | `string` | `"application"` | Load balancer type |
| `variable_lb_listener_port` | `number` | `80` | Port the ALB listener accepts traffic on |
| `variable_lb_listener_protocol` | `string` | `"HTTP"` | Protocol for the ALB listener and Target Group |
| `variable_lb_listener_rule_priority` | `number` | `100` | Priority of the ALB listener rule |
| `variable_lb_listener_rule_action_type` | `string` | `"forward"` | Action type for the ALB listener rule |
| `variable_lb_listener_rule_condition_path_pattern_values` | `list(string)` | `["*"]` | Path pattern(s) matched by the ALB listener rule |
| `variable_lb_da_type` | `string` | `"fixed-response"` | Default action type for the ALB listener |
| `variable_lb_da_fixed_response_code` | `number` | `200` | HTTP status code for the listener's fixed-response default action |
| `variable_lb_da_fixed_response_content_type` | `string` | `"text/plain"` | Content type for the listener's fixed-response default action |
| `variable_lb_da_fixed_response_message_body` | `string` | `"Welcome to the web servers"` | Message body for the listener's fixed-response default action |
| `variable_lb_tg_name` | `string` | `"web-tg"` | Name of the ALB Target Group |
| `variable_alb_tg_health_check` | `object` | See below | Health check configuration for the Target Group |
| `variable_alb_sg_name` | `string` | `"alb-sg"` | Name of the ALB security group |
| `variable_alb_sg_egress_port` | `number` | `0` | Egress from-/to-port for the ALB security group (`0` means all) |
| `variable_alb_sg_egress_protocol` | `string` | `"-1"` | Egress protocol for the ALB security group (`-1` means all) |
| `variable_security_group_name` | `string` | `"web-sg"` | Name of the EC2 instance security group |
| `varibale_sg_cidr_block` | `list(string)` | `["0.0.0.0/0"]` | CIDR blocks applied to both security group ingress/egress rules |
| `variable_sg_protocol` | `string` | `"tcp"` | IP protocol for security group ingress rules |
| `variable_data_filter_name` | `string` | `"name"` | Filter field used to look up the AMI |
| `variable_data_filter_values` | `list(string)` | `["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]` | Filter values used to look up the Ubuntu 22.04 AMI |
| `variable_data_owner` | `list(string)` | `["099720109477"]` | AWS account ID(s) that own the AMI (Canonical's ID by default) |
| `variable_user_data_bool` | `bool` | `true` | Reserved for future use; not currently referenced by any resource |

#### `variable_alb_tg_health_check` object default

```hcl
{
  path                = "/"
  protocol            = "HTTP"
  matcher             = "200"
  interval            = 15
  timeout             = 3
  healthy_threshold   = 2
  unhealthy_threshold = 2
}
```

## Outputs

| Name | Description |
|------|-------------|
| `alb_dns_name` | DNS name of the Application Load Balancer — use this to reach the cluster |
| `asg_name` | Name of the Auto Scaling Group |
| `tg_arn` | ARN of the ALB Target Group |

## Known Limitations & Gotchas

- **Default VPC only.** The module always uses the account's default VPC and its subnets. Deploying into a custom VPC is not supported.
- **Typo in variable name.** The CIDR block variable is named `varibale_sg_cidr_block` (note the transposed letters). Use this exact spelling when overriding it.
- **Resource name collisions.** Resource names (ALB, Target Group, Security Groups, Launch Template) default to generic values (`web-lb`, `web-tg`, `alb-sg`, `web-sg`, `web-launch`). Deploying more than one instance of this module into the same AWS account and region without customizing every naming variable will cause conflicts.
- **Provider block inside module.** The module declares its own `provider "aws"` block, which is an anti-pattern. The region set via `variable_region` takes precedence for all resources in this module regardless of the calling root module's provider configuration.
- **`variable_lb_listener_rule_action_target_group_arn` has no effect.** This variable is declared but is not wired to any resource. The listener rule always forwards to the Target Group created by this module.
- **`variable_user_data_bool` has no effect.** This variable is declared but not referenced anywhere in `main.tf`.
- **Plain HTTP only.** The cluster is configured for HTTP (port 80 inbound, port 8080 on instances) with no HTTPS/TLS support.
