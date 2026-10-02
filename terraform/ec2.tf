data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Cle SSH : seule la cle PUBLIQUE est envoyee a AWS.
# La cle privee reste sur le poste de l'administrateur (jamais dans Git).
resource "aws_key_pair" "admin" {
  key_name   = "${var.project_name}-admin-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.admin.key_name
  associate_public_ip_address = true

  # Disque systeme CHIFFRE (cle KMS geree par AWS aws/ebs)
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-web-01"
    Role = "webserver"
  }
}
