output "cloudfront_url" {
  description = "URL publique HTTPS du site MediTrack Online"
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "Identifiant de la distribution CloudFront"
  value       = aws_cloudfront_distribution.site.id
}

output "s3_bucket_name" {
  description = "Bucket S3 prive contenant le site statique"
  value       = aws_s3_bucket.site.id
}

output "vpc_id" {
  description = "Identifiant du VPC MediTrack"
  value       = aws_vpc.main.id
}

output "ec2_public_ip" {
  description = "Adresse IP publique du serveur web"
  value       = aws_instance.web.public_ip
}

output "ec2_web_url" {
  description = "URL du serveur web Nginx (apres execution d'Ansible)"
  value       = "http://${aws_instance.web.public_ip}"
}

output "ssh_command" {
  description = "Commande de connexion SSH a l'instance"
  value       = "ssh -i ~/.ssh/meditrack ubuntu@${aws_instance.web.public_ip}"
}
