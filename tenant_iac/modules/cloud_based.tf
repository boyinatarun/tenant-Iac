

# ############## VPC ############
# resource "aws_vpc" "this" {
#   cidr_block = var.vpc_cidr
#   tags = {
#     Name   = "${var.tenant_name}-vpc"
#     Tenant = var.tenant_name
#   }
# }

# ############ Internet Gateway ############
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.this.id
#   tags = { Name = "${var.tenant_name}-igw" }


#   depends_on = [ aws_vpc.this ]
# }

# ############ Subnets (public) ##########

# resource "aws_subnet" "public" {
#   for_each = toset(var.public_subnets)

#   vpc_id                  = aws_vpc.this.id
#   cidr_block              = each.key
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "${var.tenant_name}-public-${each.key}"
#   }

#   depends_on = [ aws_vpc.this ]
# }

# ########### route table for public subnets ############


# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.this.id
#   tags = { Name = "${var.tenant_name}-public-rt" }
# }

# resource "aws_route" "default_route" {
#   route_table_id         = aws_route_table.public_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.igw.id
# }

# resource "aws_route_table_association" "pub_assoc" {
#   for_each       = aws_subnet.public
#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.public_rt.id
# }



# resource "aws_security_group" "alb_sg" {
#   name        = "${var.tenant_name}-alb-sg"
#   description = "Allow HTTP/HTTPS from internet"
#   vpc_id      = aws_vpc.this.id

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = { Name = "${var.tenant_name}-alb-sg" }

#   depends_on = [ aws_vpc.this ]
# }

# resource "aws_security_group" "ec2_sg" {
#   name        = "${var.tenant_name}-ec2-sg"
#   description = "Allow traffic from ALB on 443"
#   vpc_id      = aws_vpc.this.id

#   ingress {
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [aws_security_group.alb_sg.id]
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [var.ssh_cidr]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = { Name = "${var.tenant_name}-ec2-sg" }

#   depends_on = [ aws_vpc.this ]
# }


# resource "aws_security_group" "ec2_sg" {
#   name   = "${var.tenant_name}-ec2-sg"
#   vpc_id = aws_vpc.this.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [var.ssh_cidr]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = { Name = "${var.tenant_name}-ec2-sg" }
# }


# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

# data "template_file" "userdata" {
#   template = file("${path.module}/userdata.sh")
#   vars     = { tenant_name = var.tenant_name }
# }

# # Generate RSA key pair locally
# resource "tls_private_key" "tenant_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# # Create AWS key pair using the public key
# resource "aws_key_pair" "tenant_key" {
#   key_name   = "${var.tenant_name}-keyname"
#   public_key = tls_private_key.tenant_key.public_key_openssh
# }

# ######## secrets manager #########
# resource "aws_secretsmanager_secret" "tenant_key_secret" {
#   name        = "${var.tenant_name}-ssh-key-secret-tenant"
#   description = "SSH private key for ${var.tenant_name}"
#   depends_on  = [ aws_key_pair.tenant_key ] 
# }


# resource "aws_secretsmanager_secret_version" "tenant_key_secret_version" {
#   secret_id     = aws_secretsmanager_secret.tenant_key_secret.id
#   secret_string = tls_private_key.tenant_key.private_key_pem
# }

# ########### ec2 instance ###########

# resource "aws_instance" "web" {
#   ami                         = data.aws_ami.amazon_linux.id
#   instance_type               = var.instance_type
#   subnet_id                   = element(values(aws_subnet.public)[*].id, var.ec2_subnet_index)
#   vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
#   associate_public_ip_address = true
#   key_name                    = aws_key_pair.tenant_key.key_name
#   user_data                   = data.template_file.userdata.rendered

#   tags = { Name = "${var.tenant_name}-web", Tenant = var.tenant_name }

#   depends_on = [ aws_subnet.public , aws_key_pair.tenant_key]
# }


######################
# # ALB
# ######################
# resource "aws_lb" "this" {
#   name               = "${var.tenant_name}-alb"
#   load_balancer_type = "application"
#   subnets            = values(aws_subnet.public)[*].id
#   security_groups    = [aws_security_group.alb_sg.id]
#   tags = {
#     Tenant = var.tenant_name
#     Name   = "${var.tenant_name}-alb"
#   }

#   depends_on = [
#     aws_subnet.public,
#     aws_security_group.alb_sg
#   ]
# }

# ######################
# # Target Group
# ######################
# resource "aws_lb_target_group" "tg" {
#   name     = "${var.tenant_name}-tg"
#   port     = 443
#   protocol = "HTTPS"
#   vpc_id   = aws_vpc.this.id

#   health_check {
#     path                = "/"
#     protocol            = "HTTPS"
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 5
#     interval            = 30
#   }

#   depends_on = [
#     aws_vpc.this
#   ]
# }

# ######################
# # Target Group Attachment
# ######################
# resource "aws_lb_target_group_attachment" "attach" {
#   target_group_arn = aws_lb_target_group.tg.arn
#   target_id        = aws_instance.web.id
#   port             = 443

#   depends_on = [
#     aws_lb_target_group.tg,
#     aws_instance.web
#   ]
# }

# ######################
# # ACM Certificate
# ######################
# resource "aws_acm_certificate" "public_cert" {
#   domain_name       = "${var.domain_name}.${var.hosted_zone_name}"
#   validation_method = "DNS"

#   lifecycle { 
#     create_before_destroy = true 
#   }

#   tags = { Tenant = var.tenant_name }
# }

# ######################
# # Route53 Validation Record
# ######################
# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.public_cert.domain_validation_options : dvo.domain_name => dvo
#   }

#   zone_id = var.hosted_zone_id
#   name    = each.value.resource_record_name
#   type    = each.value.resource_record_type
#   ttl     = 300
#   records = [each.value.resource_record_value]

#   depends_on = [
#     aws_acm_certificate.public_cert 
#   ]
# }

# ######################
# # ACM Certificate Validation
# ######################
# resource "aws_acm_certificate_validation" "public_cert_validation" {
#   certificate_arn         = aws_acm_certificate.public_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

#   depends_on = [
#     aws_route53_record.cert_validation  
#   ]
# }

# ######################
# # HTTPS Listener
# ######################
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate_validation.public_cert_validation.certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg.arn
#   }

#   depends_on = [
#     aws_lb.this,
#     aws_acm_certificate_validation.public_cert_validation,
#     aws_lb_target_group.tg
#   ]
# }

# ######################
# # HTTP Listener → HTTPS Redirect
# ######################
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }

#   depends_on = [
#     aws_lb.this
#   ]
# }

######################
# Route53 DNS Alias for ALB
######################
# resource "aws_route53_record" "dns" {
#   zone_id = var.hosted_zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_lb.this.dns_name
#     zone_id                = aws_lb.this.zone_id
#     evaluate_target_health = false
#   }

#   depends_on = [
#     aws_lb.this
#   ]
# }



############## variables ################


#variable "tenant_name" {
#     type = string
# }
# variable "vpc_cidr" {
#     type = string
# }
# variable "public_subnets" {
#   type = list(string)
# }
# variable "ec2_subnet_index" {
#     type = number
# }
# variable "instance_type" {
#     type = string
# }
# variable "domain_name" {
#     type = string
# }
# variable "hosted_zone_id" {
#     type = string
# }
# variable "ssh_cidr" {
#   type    = string
#   default = "0.0.0.0/0"
# }

# variable "hosted_zone_name" {
#   type        = string
# }