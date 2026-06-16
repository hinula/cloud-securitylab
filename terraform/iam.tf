# =============================================================
# STAGE 2: IAM Privilege Escalation
# =============================================================

resource "aws_iam_user" "low_priv_user" {
  name = "${var.lab_prefix}-dev-user"
  tags = { Stage = "2-IAM-PrivEsc" }
}

resource "aws_iam_access_key" "low_priv_key" {
  user = aws_iam_user.low_priv_user.name
}

resource "aws_iam_user_policy" "low_priv_policy" {
  name = "DevUserPolicy"
  user = aws_iam_user.low_priv_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3ReadAccess"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = "*"
      },
      {
        
        Sid      = "DangerousIAMPermission"
        Effect   = "Allow"
        Action   = [
          "iam:AttachUserPolicy",
          "iam:ListPolicies",
          "iam:GetPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "admin_role" {
  name = "${var.lab_prefix}-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = { Stage = "2-IAM-PrivEsc" }
}

resource "aws_iam_role_policy_attachment" "admin_role_policy" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
