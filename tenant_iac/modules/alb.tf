# ############ ALB ############
# resource "aws_lb" "alb" {
#   name               = "${var.tenant_name}-alb"
#   load_balancer_type = "application"
#   subnets            = values(aws_subnet.public)[*].id
#   security_groups    = [aws_security_group.alb_sg.id]
# }

# resource "aws_lb_target_group" "tg" {
#   name     = "${var.tenant_name}-tg"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.this.id
# }

# resource "aws_lb_target_group_attachment" "attach" {
#   target_group_arn = aws_lb_target_group.tg.arn
#   target_id        = aws_instance.web.id
#   port             = 80
# }

# ############ ALB Listener (HTTPS using self-signed cert) ############


# resource "tls_private_key" "alb_cert_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# resource "tls_self_signed_cert" "alb_cert" {
#   key_algorithm   = "RSA"
#   private_key_pem = tls_private_key.alb_cert_key.private_key_pem

#   subject {
#     common_name = "${var.domain_name}.duckdns.org"
#   }

#   validity_period_hours = 8760
#   is_ca_certificate     = false

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth"
#   ]
# }

# ##### adding listners ##########

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = aws_acm_certificate.alb_cert.arn
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.tg.arn
#   }
# }

# ############ DuckDNS Update ############
# resource "http_request" "duckdns_cname" {
#   url = "https://www.duckdns.org/update?domains=${var.domain_name}&token=${var.duckdns_token}&ip=${aws_lb.alb.dns_name}"
#   method = "GET"
#   depends_on = [aws_lb.alb]
# }
