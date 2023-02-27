variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
######### Token #########
variable "access_key" {
    default = "access_key_here"
}
variable "secret_key" {
    default = "secret_key_here"
}
######### VPC #########
variable "vpc_name" {
    default = "eks-vpc"
}
######### EKS #########
variable "cluster_name" {
    default = "eks-cluster"
}
variable "cluster_version" {
    default = "1.24"
}
######### Node_Groups #########
variable "node_instance_types" {
  type        = string
  default = "t3.medium"
}
variable "node_ami_type" {
    default = "AL2_x86_64"
}
variable "node_disk_size" {
    default = "20"
}
variable "node_desired_size" {
    default = "1"
}
variable "node_min_size" {
    default = "1"
}
variable "node_max_size" {
    default = "1"
}
