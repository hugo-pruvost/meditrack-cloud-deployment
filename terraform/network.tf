data "aws_availability_zones" "available" {
  state = "available"
}

# --- VPC dedie au projet ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# --- Passerelle Internet : sortie vers Internet du sous-reseau public ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# --- Sous-reseau public (heberge le serveur web EC2) ---
# Pas d'IP publique automatique : seule l'instance web en demande une explicitement.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-subnet-public"
    Tier = "public"
  }
}

# --- Table de routage : trafic Internet (0.0.0.0/0) via la passerelle ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Groupe de securite du serveur web (pare-feu AWS) ---
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Serveur web MediTrack : HTTP public, SSH reserve a l'administrateur"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# SSH (22) : UNIQUEMENT depuis l'IP de l'administrateur
resource "aws_vpc_security_group_ingress_rule" "ssh_admin" {
  security_group_id = aws_security_group.web.id
  description       = "SSH administrateur uniquement"
  cidr_ipv4         = var.admin_ip_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

# HTTP (80) : acces au serveur web Nginx
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP serveur web Nginx"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# Sortie : necessaire pour les mises a jour systeme (apt) et l'installation de Nginx
resource "aws_vpc_security_group_egress_rule" "all_out" {
  security_group_id = aws_security_group.web.id
  description       = "Sortie vers Internet (mises a jour)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
