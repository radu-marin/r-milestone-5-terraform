# Create users
resource "aws_iam_user" "users" {
    count = length(var.user_names)
    name = var.user_names[count.index]
}

# Define the policy (json) using tf inbuilt aws_iam_policy_document data source
data "aws_iam_policy_document" "ec2_read_only" {
    statement {
      effect = "Allow"
      actions = ["ec2:Describe"]
      resources = ["*"]
    }
}

# Create IAM policy from aws_iam_policy_document
resource "aws_iam_policy" "ec2_read_only" {
    name = "ec2-read-only"
    policy = data.aws_iam_policy_document.ec2_read_only.json
}

# Attach the IAM policy to users
resource "aws_iam_user_policy_attachment" "ec2_access" {
    count = length(var.user_names)
    user = element(aws_iam_user.users[*].name, count.index) 
    policy_arn = aws_iam_policy.ec2_read_only.arn
} # OBS: could also user = use aws_iam_user.users[count.index].name, 
  # but there is a diffrenece when accessing out of bond indexes.

