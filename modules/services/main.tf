
# <======================   DATA SOURCES   ======================>
# Fetch 'terraform_remote_state' data to get previous network info outputs
data "terraform_remote_state" "network" {
    backend = "s3"
    config = {
        bucket = var.network_remote_state_bucket
        key = var.network_remote_state_key
        region = var.region
    }
}

# Read remote MySQL db tf state data
data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key #path in bucket
    region = var.region
  } 
}

# Import the AWS secret version created previously to fetch db password
data "aws_secretsmanager_secret_version" "db_pass" {
  secret_id = data.terraform_remote_state.db.outputs.dbpass_secret_arn
} # with data.aws_secretsmanager_secret_version.db_pass.secret_string attribute - can decrypt and retrieve pass

# All the database’s output variables are stored in the state file and you can read them 
# from the terraform_remote_state data source using an attribute reference of the form:
# data.terraform_remote_state.<NAME>.outputs.<ATTRIBUTE>


# <======================   EC2 INSTANCES   ======================>
# Create an EC2 instance in private subnet, as webserver:
resource "aws_instance" "web_server" {
    ami = var.web_server_ami
    instance_type = var.web_server_instance_type
    subnet_id = data.terraform_remote_state.network.outputs.prv1_subnet_id
    vpc_security_group_ids = [data.terraform_remote_state.network.outputs.prv_sg_id] 
    
    user_data = templatefile("${path.module}/user-data-ws-single.tftpl",
    { 
        webapp_link = var.webapp_repo_link
        db_address = data.terraform_remote_state.db.outputs.address
        db_user = data.terraform_remote_state.db.outputs.user
        db_port = data.terraform_remote_state.db.outputs.port
        db_name = data.terraform_remote_state.db.outputs.db_name
        db_pass = data.aws_secretsmanager_secret_version.db_pass.secret_string
    }) # assign variables here, reference with ${var_name} in .tftpl file

    tags = {
        Name = "r-milestone-5-${var.environment}-webserver"
        Owner = var.owner
    }

    iam_instance_profile = aws_iam_instance_profile.ws_profile.id
}

# Create an EC2 instance in public subnet, as bastion:
resource "aws_instance" "bastion" {
    ami = var.bastion_ami
    instance_type = var.bastion_instance_type
    subnet_id = data.terraform_remote_state.network.outputs.pub1_subnet_id
    vpc_security_group_ids = [
    data.terraform_remote_state.network.outputs.pub_sg_id, 
    data.terraform_remote_state.network.outputs.bastion_sg_id
    ]
    
    user_data = templatefile("${path.module}/user-data-bastion.tftpl",
    { 
    }) # assign variables here, reference with ${var_name} in .tftpl file

    tags = {
        Name = "r-milestone-5-${var.environment}-bastion"
        Owner = var.owner
    }

    # OBS: used the same profile as web server
    iam_instance_profile = aws_iam_instance_profile.ws_profile.id

    # Associate public ip address for ssh
    associate_public_ip_address = true

    # Attached public key for ssh
    key_name = aws_key_pair.bastion_pub_key.key_name
}

# !! OBS: replace pub key with your own key !!
# Create SSH key resource for bastion and insert public ssh key here:
resource "aws_key_pair" "bastion_pub_key" {
    key_name = "r-bastion-${var.environment}-ssh-pub-key"
    public_key = file("${path.module}/r-ms5-bastion.pub")
}


# <====================   INSTANCE PROFILES   ====================>
# Create instance profile which allows the EC2 instance to access S3 buckets
resource "aws_iam_instance_profile" "ws_profile" {
  name = "r-${var.environment}-ws-profile"
  role = aws_iam_role.ws_role.name
}

# Create role with s3 full access and SSM for instance profile (ws_profile) 
resource "aws_iam_role" "ws_role" {
  name = "r-${var.environment}-ws-role"
  path = "/"
  #OBS: inserted json file directly
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "r-${var.environment}-ws-role"
    Owner = var.owner
  }
}

# Attach policies to ws_role
resource "aws_iam_role_policy_attachment" "attachment" {
  role = aws_iam_role.ws_role.name
  count = length(var.ws_iam_policy_arn)
  policy_arn = var.ws_iam_policy_arn[count.index]
}


# <====================   AUTO SCALING GROUP   ====================>
# Create the launch configuration for Web Server Auto Scaling Group
resource "aws_launch_configuration" "ws_asg_config" {
    image_id = var.web_server_ami
    instance_type = var.web_server_instance_type
    security_groups = [data.terraform_remote_state.network.outputs.prv_sg_id]

    user_data = templatefile("${path.module}/user-data-ws-asg.tftpl",
    { 
        webapp_link = var.webapp_repo_link
        db_address = data.terraform_remote_state.db.outputs.address
        db_user = data.terraform_remote_state.db.outputs.user
        db_port = data.terraform_remote_state.db.outputs.port
        db_name = data.terraform_remote_state.db.outputs.db_name
        db_pass = data.aws_secretsmanager_secret_version.db_pass.secret_string
    })

    iam_instance_profile = aws_iam_instance_profile.ws_profile.id
}

# Create the ASG for webapp servers:
resource "aws_autoscaling_group" "ws_asg" {
    launch_configuration = aws_launch_configuration.ws_asg_config.name
    vpc_zone_identifier = [
        data.terraform_remote_state.network.outputs.prv1_subnet_id,
        data.terraform_remote_state.network.outputs.prv2_subnet_id
    ]

    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    min_size = var.min_size
    max_size = var.max_size

    tag {
        key = "Name"
        value = "r-milestone-5-${var.environment}-ws-asg"
        propagate_at_launch = true
    }
}


# <====================   APP LOAD BALANCER   ====================>
# Multiple servers, each with own IP => need to offer users a single IP to connect 
# => Create Application Load Balancer
resource "aws_lb" "alb_asg" {
    name = "r-milestone-5-${var.environment}-alb-asg"
    load_balancer_type = "application"
    # subnets public !!! ()
    subnets = [
      data.terraform_remote_state.network.outputs.pub1_subnet_id,
      data.terraform_remote_state.network.outputs.pub2_subnet_id
    ]
    security_groups = [data.terraform_remote_state.network.outputs.pub_sg_id] #added after creating sg resource

    tags = {
      Name = "r-milestone-5-${var.environment}-alb"
      Owner = var.owner
    }
}

# Create a target group that ALB uses for ASG:
resource "aws_lb_target_group" "asg" {
  name     = "r-milestone-5-${var.environment}-alb-target"
  port     = 8080 #here is where redirection from 80 to 8080 takes place
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.main_vpc_id
}

# Define a listener for the ALB:
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb_asg.arn
  port = 80 
  protocol = "HTTP"

  # By default, return a simple 404 page (for requests that don't match any listener rules)
  default_action{
    type = "fixed-response" #should I change to "forward" ?

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found. Oh no..."
      status_code = 404
    }

    # # also tried:
    # forward {
    #   target_group {
    #     arn = aws_lb_target_group.asg.arn
    #     weight = 100
    #   }
    # }
  }
}

# Tie the previous pieces together by creating listener rules:
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}