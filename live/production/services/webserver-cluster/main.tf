# live/production/services/webserver-cluster/main.tf

module "webserver_cluster" {
  source = "github.com/haxor44/cluster-modules//modules/services/webserver-cluster?ref=v0.0.1"

  cluster_name  = "webservers-production"
  variable_instance_type = "t2.medium"
  variable_min_size      = 4
  variable_max_size      = 10
}