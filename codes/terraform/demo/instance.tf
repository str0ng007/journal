resource "aws_key_pair" "demo_key" {
  key_name   = "demo-key"
  public_key = var.public_key

}

resource "aws_instance" "web" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.demo1.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.demo_external.id]
  key_name                    = aws_key_pair.demo_key.key_name

  dynamic "root_block_device" {
    for_each = var.root_block_device

    content {
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
    }
  }

  count = var.instance_count

  tags = {
    Name = "Demo"
  }

}
