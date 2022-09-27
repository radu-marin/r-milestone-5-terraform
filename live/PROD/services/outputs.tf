output "bastion_public_ip" {
    description = "Bastion public ip"
    value = module.services.bastion_public_ip
}

output "ws_single_prv_ip" {
    description = "Private ip for single instance (non asg) for tests"
    value = module.services.ws_single_prv_ip
}

output "alb_dns_name" {
    description = "The domain name of the app load balancer" 
    value = module.services.alb_dns_name 
}

output "ssh_port_forwarding_command" {
    description = "Run this command to port forward through bastion"
    value = module.services.ssh_port_forwarding_command
}