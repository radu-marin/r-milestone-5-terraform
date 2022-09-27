**Milestone 5 - Terraform**

This is my Terraform project for milestone 5, DevOps apprenticeship at Nagarro Romania.

Deployment Order:
1) Authenticate with you own aws credentials:
````
export AWS_ACCESS_KEY_ID=<your_aws_access_key_id>
export AWS_SECRET_ACCESS_KEY=<your_aws_secret_key>
```
2) Go inside `global/s3` directory and create S3 backend with dynamodb that will host all your terraform state files
(`terraform init` and `terraform apply`)

3) Switch to `live/DEV/network`  or `live/PROD/network` directory and create Network infrastructure by running `terraform init` and `terraform apply` 

4) Switch to `data-storage` directory from your environment (DEV/PROD) and create MySQL database for webapp (Check main.tf for desired attributes) and then run  `terraform init` and `terraform apply`
OBS: Password will be automatically generated for main db user and stored as a secret (check aws secrets manager)

5) Change directory to `modules/services` , open the r-ms5-bastion.pub file, and replace that key with your own public key (it will be used to connect via ssh to bastion)

6) Change directory to `live/DEV/services` or `live/PROD/network` and create instances that host your webapp (check main.tf for proper arguments) (run terraform init and apply as before)
OBS: The previously generated password for db will be automatically inserted.

7) Use the output (bastion public ip) to connect via ssh and manage port forward to test webapp: `ssh ec2-user@<bastion_pub_ip> -i ~/.ssh/r-ms5-bastion -L 9090:<webhost_prv_ip>:8080`
and check running app on `localhost:9090`
