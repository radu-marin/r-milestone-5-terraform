## Milestone 5 - Terraform
This is my Terraform project for milestone 5, DevOps apprenticeship at Nagarro Romania.
***
**Project Description/Contents:**
- dual environement construction : `DEV` and `PROD` that use modules hosted in `modules` directory (please check tree diagram):
```
├── live
│   ├── DEV
│   │   ├── data-storage
│   │   ├── network
│   │   └── services
│   ├── PROD
│   │   ├── data-storage
│   │   ├── network
│   │   └── services
│   └── global
│       ├── iam
│       └── s3
└── modules
    ├── data-storage
    ├── network
    └── services
```
- all terraform state files are contained in an s3 backend (check `live/global` for creation )
- the network infrastructure consists of : 1 VPC, 2 public subnets, 2 private subnets, 1 internet gateway, 1 nat gateway, 1 public routing table, 1 private routing table. (check `modules/network`)
- security groups: 1 sg for pub subnets, 1 sg for bastion, 1 sg for prv subnets.
- In public subnet (no.1) we have 1 Bastion Host to which we can connect via SSH or SSM. We use it to port forward from a single EC2 instance that hosts a website to our client machine.
- In the private subnet (no.1) we have the single EC2 instance mentioned before.
- In both private subnets (1 and 2) we have an ASG used to deploy our webapp, that is linked to an App Load Balancer (located in both public subnets). 


***
**Deployment Order:**
1) Go inside `global/s3` directory and create S3 backend with dynamodb that will host all your terraform state files
(`terraform init` and `terraform apply`)
2) Switch to `live/DEV/network`  or `live/PROD/network` directory and create Network infrastructure by running `terraform init` and `terraform apply` 
3) Switch to `data-storage` directory from your environment (DEV/PROD) and create MySQL database for webapp (Check main.tf for desired attributes) and then run  `terraform init` and `terraform apply` . An random password for the db will be generated and stored in aws secrets manager (will be later fetched in services for log in)
4) Change directory to `modules/services` , open the r-ms5-bastion.pub file, and replace that key with your own public key (it will be used to connect via ssh to bastion)
5) Change directory to `live/DEV/services` or `live/PROD/network` and create instances that host your webapp (check main.tf for proper arguments) (run terraform init and apply as before)
6) Use the output to view the website: 
- via alb_dns_name for the ASG
- via the displayed command for ssh port forwarding for the single instance web server.
