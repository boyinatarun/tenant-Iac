

############## VPC ############
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name   = "${var.tenant_name}-vpc"
    Tenant = var.tenant_name
  }
}

############ Internet Gateway ############
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.tenant_name}-igw" }


  depends_on = [ aws_vpc.this ]
}

############ Subnets (public) ##########

resource "aws_subnet" "public" {
  for_each = toset(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tenant_name}-public-${each.key}"
  }

  depends_on = [ aws_vpc.this ]
}

########### route table for public subnets ############


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.tenant_name}-public-rt" }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "pub_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}



