

# Generate RSA key pair locally
resource "tls_private_key" "tenant_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create AWS key pair using the public key
resource "aws_key_pair" "tenant_key" {
  key_name   = "${var.tenant_name}-keyname"
  public_key = tls_private_key.tenant_key.public_key_openssh
}

######## secrets manager #########
resource "aws_secretsmanager_secret" "tenant_key_secret" {
  name        = "${var.tenant_name}-secret-key-tenant-ssh"
  description = "SSH private key for ${var.tenant_name}"
  depends_on  = [ aws_key_pair.tenant_key ] 
}


resource "aws_secretsmanager_secret_version" "tenant_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.tenant_key_secret.id
  secret_string = tls_private_key.tenant_key.private_key_pem
}

########### ec2 instance ###########

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# data "template_file" "userdata" {
#   template = file("${path.module}/userdata.sh")
#     vars = {
#     tenant_name = var.tenant_name
#   }
# }

# resource "aws_instance" "web" {

#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = var.instance_type
#   subnet_id                   = element(values(aws_subnet.public)[*].id, var.ec2_subnet_index)
#   vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
#   associate_public_ip_address = true
#   user_data                   = data.template_file.userdata.rendered
#   tags                        = { Name = "${var.tenant_name}-web", Tenant = var.tenant_name }
#   key_name                    = aws_key_pair.tenant_key.key_name
# #  depends_on                  = [ aws_subnet.public , aws_key_pair.tenant_key, aws_security_group.ec2_sg ]

# }


# Use templatefile function instead of deprecated template_file data source
# resource "aws_instance" "web" {
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = var.instance_type
#   subnet_id                   = element(values(aws_subnet.public)[*].id, var.ec2_subnet_index)
#   vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
#   associate_public_ip_address = true
#   key_name                    = aws_key_pair.tenant_key.key_name

#   user_data = templatefile("${path.module}/userdata.sh", {
#     tenant_name   = var.tenant_name
#     # duckdns_token = var.duckdns_token
#     # cert_dir      = "/etc/nginx/ssl"
#     cert_pem      = tls_self_signed_cert.tenant_cert.cert_pem
#     key_pem       = tls_private_key.tenant_tls_key.private_key_pem
#   })


#   tags = { 
#     Name   = "${var.tenant_name}-web", 
#     Tenant = var.tenant_name 
#   }
# }




# resource "null_resource" "duckdns_update" {
#   # Trigger only when public IP changes
#   triggers = {
#     ip = aws_instance.web.public_ip
#   }

#   provisioner "local-exec" {
#     command = <<EOT
# curl -s "https://www.duckdns.org/update?domains=${var.domain_name}&token=${var.duckdns_token}&ip=${aws_instance.web.public_ip}" || true
# EOT
#   }
# }


resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = element(values(aws_subnet.public)[*].id, var.ec2_subnet_index)
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name               = aws_key_pair.tenant_key.key_name

  user_data = templatefile("${path.module}/userdata.sh", {
    tenant_name     = var.tenant_name
    duckdns_token   = var.duckdns_token
    custom_cert_pem = var.custom_cert_pem != null ? var.custom_cert_pem : ""
    custom_key_pem  = var.custom_key_pem  != null ? var.custom_key_pem  : ""  
  })

  tags = {
    Name   = "${var.tenant_name}-web"
    Tenant = var.tenant_name
  }
}

