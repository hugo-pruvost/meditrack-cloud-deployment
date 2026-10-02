variable "aws_region" {
  description = "Region AWS de deploiement. Paris (eu-west-3) : donnees hebergees en France (RGPD / HDS)."
  type        = string
  default     = "eu-west-3"
}

variable "aws_profile" {
  description = "Profil AWS CLI contenant les cles de l'utilisateur IAM terraform-meditrack."
  type        = string
  default     = "meditrack"
}

variable "project_name" {
  description = "Prefixe des ressources. Doit commencer par 'meditrack' (politique IAM limitee aux buckets meditrack-*)."
  type        = string
  default     = "meditrack"
}

variable "vpc_cidr" {
  description = "Plage d'adresses IP privees du VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Plage d'adresses du sous-reseau public qui heberge le serveur web."
  type        = string
  default     = "10.0.1.0/24"
}

variable "admin_ip_cidr" {
  description = "Adresse IP publique de l'administrateur au format CIDR (ex : 203.0.113.10/32). Seule cette IP peut se connecter en SSH."
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2 (legere et economique)."
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key_path" {
  description = "Chemin de la cle SSH PUBLIQUE envoyee a AWS (la cle privee reste sur le poste)."
  type        = string
  default     = "~/.ssh/meditrack.pub"
}
