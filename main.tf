provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_availability_zones" "available" {}


data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}

provider "kubernetes" {
  host = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.default.token
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = var.vpc_name

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  cluster_enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = var.node_ami_type
    disk_size = var.node_disk_size
  }

  #aws-auth configmap
  manage_aws_auth_configmap = true

  aws_auth_users = [
      {
		# Replace XXXX with username that you want to add it to kubernetes.
		# Replace eks-user with name of username that you want to add it to kubernetes.
        userarn  = "arn:aws:iam::XXXXXXXXXX:user/eks-user"
        username = "eks-iser"
        groups   = ["system:masters"]
      },
  ]

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"
      instance_types = ["${var.node_instance_types}"]
      disk_size = var.node_disk_size
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size
    }

    two = {
      name = "node-group-2"
      instance_types = ["${var.node_instance_types}"]
      disk_size = var.node_disk_size
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size
   }
  }
}

