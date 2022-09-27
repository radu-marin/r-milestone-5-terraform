output "all_arns" {
    description = "The ARNs for all users"
    value = aws_iam_user.users[*].arn
}