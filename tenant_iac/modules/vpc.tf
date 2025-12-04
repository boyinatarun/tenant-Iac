

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


resource "aws_subnet" "private" {
  for_each = toset(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tenant_name}-private-${each.key}"

  }
  depends_on = [ aws_vpc.this]
}
 


resource "aws_eip" "nat" {
  count = var.enable_nat ? 1 : 0
  domain = "vpc"   

  tags = {
    Name = "${var.tenant_name}-nat-eip"
  }
}


resource "aws_nat_gateway" "nat_gw" {
  count = var.enable_nat ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = element([for s in aws_subnet.public : s.id], var.ec2_subnet_index) 

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.tenant_name}-nat-gateway"
  }
}


resource "aws_route_table" "private_rt" {
  count = var.enable_nat ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.tenant_name}-private-rt"
  }
}

resource "aws_route" "private_default_route" {
  count = var.enable_nat ? 1 : 0

  route_table_id         = aws_route_table.private_rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = var.enable_nat ? aws_subnet.private : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[0].id
}



