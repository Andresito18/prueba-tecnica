provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "education-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "mongodb" {
  source                = "toluna-terraform/terraform-aws-mongodb"
  version               = "~>0.0.1" // Change to the required version.
  environment                 = local.environment
  app_name                    = local.app_name
  aws_profile                 = local.aws_profile
  env_type                    = local.env_type
  atlasprojectid              = var.atlasprojectid
  atlas_region                = var.atlas_region
  atlas_num_of_replicas       = local.env_vars.atlas_num_of_replicas
  backup_on_destroy           = true
  restore_on_create           = true
  allowed_envs                = local.allowed_envs
  aws_vpce                    = data.terraform_remote_state.app
  db_name                     = local.app_name
  init_db_environment         = local.init_db_environment
  init_db_aws_profile         = local.init_db_aws_profile
  atlas_num_of_shards         = 1
  mongo_db_major_version      = "4.2"
  disk_size_gb                = 10
  provider_disk_iops          = 1000
  provider_volume_type        = "STANDARD"
  provider_instance_size_name = "M10"
}
