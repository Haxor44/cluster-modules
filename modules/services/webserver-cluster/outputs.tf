output "alb_dns_name" {
    value = aws_lb.web-lb.dns_name
    description = "The DNS name of the load balancer"
}

output "asg_name" {
  value = aws_autoscaling_group.web-asg.name
  description = "The name of the auto scaling group"
}

