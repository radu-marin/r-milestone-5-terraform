variable "user_names" {
    description = "Create list of IAM users with these names"
    type = list(string)
    default = ["marius", "bogdan.s", "bogdan.c"]
}