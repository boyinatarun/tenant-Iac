

# module "tenant" {
#   for_each = var.tenants

#   source            = "./modules/"
#   tenant_name       = each.key
#   vpc_cidr          = each.value.vpc_cidr
#   public_subnets    = each.value.public_subnets
#   ec2_subnet_index  = each.value.ec2_subnet_index
#   instance_type     = each.value.instance_type
#   domain_name       = each.value.domain_name
#   hosted_zone_id    = var.hosted_zone_id
#   hosted_zone_name  = var.hosted_zone_name
#   ssh_cidr          = each.value.ssh_cidr
# }


module "tenant" {
  for_each = var.tenants
  source   = "./modules/"

  tenant_name      = each.key
  domain_name      = each.value.domain_name
  vpc_cidr         = each.value.vpc_cidr
  public_subnets   = each.value.public_subnets
  instance_type    = each.value.instance_type
  ec2_subnet_index = each.value.ec2_subnet_index
  duckdns_token    = var.duckdns_token
  ssh_cidr         = each.value.ssh_cidr
  custom_cert_pem  = lookup(each.value, "custom_cert_pem", "")
  custom_key_pem   = lookup(each.value, "custom_key_pem", "")
}
