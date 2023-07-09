## Creating users for Ops team
resource "aws_iam_user" "ops_users" {
  count = length(var.ops_users)
  name  = element(var.ops_users, count.index)
}

## Addiing profile for ops user
resource "aws_iam_user_login_profile" "add_profile" {
  count = length(var.ops_users)
  user  = element(aws_iam_user.ops_users.*.name, count.index)
}

## Creating group for Ops team
resource "aws_iam_group" "ops_group" {
  name = "ops_group"
}

## Attach users to Ops group
resource "aws_iam_group_membership" "ops_group_attachment" {
  name  = "ops-group-attachment"
  count = length(var.ops_users)
  users = [element(aws_iam_user.ops_users.*.name, count.index)]
  group = aws_iam_group.ops_group.name
}

## Attaching policy to ops group
resource "aws_iam_group_policy_attachment" "ops_policy_attach" {
  group      = aws_iam_group.ops_group.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}