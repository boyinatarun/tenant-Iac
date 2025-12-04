variable "tenant_name" {
    type = string
}
variable "domain_name" {
    type = string
}
variable "vpc_cidr" {
    type = string
}
variable "public_subnets" {
  type = list(string)
}
variable "instance_type" {
    type = string
}
variable "ec2_subnet_index" {
    type = number
}
variable "duckdns_token" {
    type = string
}
variable "ssh_cidr" {
  type    = string
}

variable "custom_cert_pem" {
  type = string
  default = ""
}

variable "custom_key_pem" {
  type = string
  default = ""
}

variable "private_subnets" {
  type = list(string)
  default = []
}

variable "enable_nat" {
  type        = bool
  default     = true
  description = "If true create NAT Gateway & Private routing"
}
