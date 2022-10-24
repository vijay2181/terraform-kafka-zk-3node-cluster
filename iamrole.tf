resource "aws_iam_role" "access_role" {
  name               = "Instance-Role"
  assume_role_policy = file("./policy/assumerolepolicy.json")
}

resource "aws_iam_policy" "policy1" {
  name        = "ECR-Policy"
  description = "Policy for pulling ECR images"
  policy      = file("./policy/ecrPullPushPolicy.json")
}

resource "aws_iam_policy" "policy2" {
  name        = "EC2-Policy"
  description = "Policy for EC2"
  policy      = file("./policy/ec2policy.json")
}

resource "aws_iam_policy" "policy3" {
  name        = "SSM-Policy"
  description = "Policy for SSM"
  policy      = file("./policy/ssmpolicy.json")
}



resource "aws_iam_policy_attachment" "policy-attach1" {
  name       = "policy-attachment1"
  roles      = ["${aws_iam_role.access_role.name}"]
  policy_arn = aws_iam_policy.policy1.arn
}

resource "aws_iam_policy_attachment" "policy-attach2" {
  name       = "policy-attachment2"
  roles      = ["${aws_iam_role.access_role.name}"]
  policy_arn = aws_iam_policy.policy2.arn
}

resource "aws_iam_policy_attachment" "policy-attach3" {
  name       = "policy-attachment3"
  roles      = ["${aws_iam_role.access_role.name}"]
  policy_arn = aws_iam_policy.policy3.arn
}

resource "aws_iam_instance_profile" "vijay_profile" {
  name = "vijay_profile"
  role = aws_iam_role.access_role.name
}
