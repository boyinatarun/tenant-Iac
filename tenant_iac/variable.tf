variable "region" {
    type = string
}

# variable "hosted_zone_id" {
#     type = string
# }

# variable "hosted_zone_name" {
#   type        = string
# }

variable "tenants" {
  type = map(object({
    vpc_cidr         = string
    public_subnets   = list(string)
    ec2_subnet_index = number
    instance_type    = string
    domain_name      = string
    ssh_cidr        = optional(string, "")
    custom_cert_pem  = optional(string)
    custom_key_pem   = optional(string)
    private_subnets  = optional(list(string), [])
    enable_nat       = optional(bool, true)
  }))
}

variable "duckdns_token" {
  type = string
}
