output "bastion_public_ip" {
    description = "Bastion public ip"
    value = aws_instance.bastion.public_ip
}

output "ws_single_prv_ip" {
    description = "Private ip for single instance (non asg) for tests"
    value = aws_instance.web_server.private_ip
}

output "alb_dns_name" {
    description = "The domain name of the app load balancer" 
    value = aws_lb.alb_asg.dns_name 
}

output "ssh_port_forwarding_command" {
    description = "Run this command to port forward through bastion"
    value = "ssh ec2-user@${aws_instance.bastion.public_ip} -i ~/.ssh/r-ms5-bastion -L 9090:${aws_instance.web_server.private_ip}:8080"
}