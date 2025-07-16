variable "region" {}
variable "vpc_id" {}
variable "vpc_cidr_block" {}
variable "subnet_id" {}
variable "instance_type" { default = "t3.small" }
variable "ssm_parameter_name" {}
variable "tws_userid" {}
variable "tws_password" {}
variable "trading_mode" { default = "live" }
