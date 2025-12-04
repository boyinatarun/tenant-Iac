

# hosted_zone_id = "Z08997892K44O4ZZ4109L" 
# hosted_zone_name = "example1.com"



# tenants = {
#   tenant1 = {
#     vpc_cidr         = "10.10.0.0/16"
#     public_subnets   = ["10.10.1.0/24", "10.10.2.0/24"]
#     ec2_subnet_index = 0
#     instance_type    = "t2.micro"
#     domain_name      = "tenant1"
#     ssh_cidr        = "106.215.174.165/32"
#   }

# #   tenant2 = {
# #     vpc_cidr         = "10.20.0.0/16"
# #     public_subnets   = ["10.20.1.0/24", "10.20.2.0/24"]
# #     ec2_subnet_index = 0
# #     instance_type    = "t2.micro"
# #     domain_name      = "tenant2"
# #     ssh_cidr        = "106.215.174.165/32"
# #   }
# }

region = "us-east-1"
duckdns_token = "791d1bb3-df97-422e-a95a-77ba8ee0d260"



tenants = {
  tenant21 = {
    domain_name      = "tenant21"
    vpc_cidr         = "10.0.0.0/16"
    public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
    instance_type    = "t2.micro"
    ec2_subnet_index = 0
    ssh_cidr        = "106.215.174.165/32"
  }
}
