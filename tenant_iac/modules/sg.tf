
resource "aws_security_group" "ec2_sg" {
  name        = "${var.tenant_name}-ec2-sg"
  description = "Allow traffic from ALB on 443"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks    = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.tenant_name}-ec2-sg" }

  depends_on = [ aws_vpc.this ]
}