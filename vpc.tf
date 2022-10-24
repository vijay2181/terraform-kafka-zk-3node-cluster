# Resources Block
# Resource-1: Create VPC
resource "aws_vpc" "myvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = "myvpc"
  }
}

# Resource-2: Create public Subnet
resource "aws_subnet" "my-public-subnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "my-public-subnet"
  }
}


# Resource-3: Internet Gateway
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    "Name" = "myIGW"
  }
}

# Resource-4: Create Route Table 1 for public subnet
resource "aws_route_table" "my-public-RT" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    "Name" = "my-public-RT"
  }
}

# Resource-5: Create Route in public Route Table for Internet Access
resource "aws_route" "vpc-public-route" {
  route_table_id         = aws_route_table.my-public-RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myIGW.id
}


# Resource-6: Associate the public Route Table with the public Subnet
resource "aws_route_table_association" "vpc-public-route-table-associate" {
  route_table_id = aws_route_table.my-public-RT.id
  subnet_id      = aws_subnet.my-public-subnet.id
}


