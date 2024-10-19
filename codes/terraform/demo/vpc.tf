data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Demo"
  }
}

resource "aws_subnet" "demo1" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Demo 1"
  }
}

resource "aws_subnet" "demo2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Demo 2"
  }

}

resource "aws_subnet" "demo3" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "Demo 3"
  }

}

resource "aws_internet_gateway" "demo_gateway" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "Demo Internet Gateway"
  }

}

resource "aws_main_route_table_association" "demo" {
  vpc_id         = aws_vpc.example.id
  route_table_id = aws_route_table.demo_route_table.id

}

resource "aws_route_table" "demo_route_table" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_gateway.id
  }

  tags = {
    Name = "Demo Route Table"
  }

}
