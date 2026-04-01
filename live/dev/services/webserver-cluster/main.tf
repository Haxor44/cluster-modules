# live/dev/services/webserver-cluster/main.tf

module "webserver_cluster" {
  source = "github.com/haxor44/cluster-modules//modules/services/webserver-cluster?ref=v0.0.2"

  cluster_name  = "webservers-dev"
  variable_instance_type = "t2.micro"
  variable_min_size      = 2
  variable_max_size      = 4
}

output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
}