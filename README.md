##

git clone <repo> (clone the repo)

cd tenant_iac/variables/us-east-1/dev.tfvars (go inside the folder)
add the required tenants in the tenants 

example:

tenants = {
  tenant21 = {
    domain_name      = "tenant21"
    vpc_cidr         = "10.0.0.0/16"
    public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
    instance_type    = "t2.micro"
    ec2_subnet_index = 0
    ssh_cidr        = "106.215.174.165/32"
    custom_cert_pem  = ""
    custom_key_pem   = ""
  },
  tenant20 = {
    domain_name      = "tenant20"
    vpc_cidr         = "10.0.0.0/16"
    public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
    instance_type    = "t2.micro"
    ec2_subnet_index = 0
    ssh_cidr        = "106.215.174.165/32"
  }
}

git commit and push the changes 

go the actions and run the tenant_iac_deployment pipeline by selecting the branch , env, region, folder path 

it will create the vpc,public subnet and userdata contains the openssl cert and sample hello world docker application for demo and if you have your own cert you can pass in the .tfvars or if we don't your certs the userdata will create it.
custom_cert_pem 
custom_key_pem

The tfstate file saved in the s3 bucket with the dynamo locking