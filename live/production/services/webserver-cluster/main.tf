# live/production/services/webserver-cluster/main.tf

module "webserver_cluster" {
  source = "../../../../modules/services/webserver-cluster"

  cluster_name  = "webservers-production"
  variable_instance_type = "t2.medium"
  variable_min_size      = 4
  variable_max_size      = 10
}