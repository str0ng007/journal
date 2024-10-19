resource "aws_security_group" "demo" {
  name        = "Demo Security Group"
  description = "This is for Demo"
  vpc_id      = aws_vpc.example.id

  ingress {
    description     = "allow ssh"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = [aws_vpc.example.cidr_block]
    security_groups = [aws_security_group.demo_external.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Demo"
  }

}

resource "aws_security_group" "demo_external" {
  name        = "Demo Security Group - External"
  description = "This is an external security group"
  vpc_id      = aws_vpc.example.id

  ingress {
    description = "allow ssh from outside"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
