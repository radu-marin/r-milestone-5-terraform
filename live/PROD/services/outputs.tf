output "bastion_public_ip" {
    description = "Bastion public ip"
    value = module.services.bastion_public_ip
}

output "alb_dns_name" {
    description = "The domain name of the app load balancer" 
    value = module.services.alb_dns_name 
}