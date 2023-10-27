// CODEBUILD + CODEPIPELINE (same policy)
data "aws_iam_policy_document" "code_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::${var.artifacts_bucket}", //USED FOR TEMPLATE ONLY
      "arn:aws:s3:::${var.artifacts_bucket}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeNetworkInterface",
      "ec2:DescribeNetworkInterfacePermission",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteNetworkInterfacePermission",
      "ec2:Describe*",
      "ec2:Get*"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codeartifact:Get*",
      "codeartifact:List*",
      "codeartifact:ReadFromRepository"

    ]

    resources = [
      "arn:aws:codeartifact:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.codeartifact_domain_name}",
      "arn:aws:codeartifact:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.codeartifact_domain_name}/*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["sts:GetServiceBearerToken"]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [
      var.kms_key_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:Get*"
    ]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.macro_project_name}-*"

    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codecommit:Get*",
      "codecommit:GitPull"
    ]
    resources = [
      "arn:aws:codecommit:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.repository_name}"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${var.repository_name}-*"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["codepipeline:StartPipelineExecution"]
    resources = ["arn:aws:codepipeline:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.macro_project_name}-*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/fermium",
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/${var.repository_name}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogDelivery",
      "logs:Describe*",
      "logs:GetLogDelivery",
      "logs:GetLogEvents",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:PutResourcePolicy",
      "logs:UpdateLogDelivery"
    ]
    resources = ["*"]
  }


}

data "aws_iam_policy_document" "assume_role_codebuild" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com",
        "codebuild.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_service_role" {
  name               = "${var.macro_project_name}-codebuild-service-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_codebuild.json
}

resource "aws_iam_role_policy" "codebuild_project_role" {
  role   = aws_iam_role.codebuild_service_role.name
  policy = data.aws_iam_policy_document.code_policy_document.json
}

// CODEPIPELINE
data "aws_iam_policy_document" "assume_role_codepipeline" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codepipeline_service_role" {
  name               = "${var.macro_project_name}-codepipeline-service-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_codepipeline.json
}

resource "aws_iam_role_policy" "codepipeline_project_role" {
  role   = aws_iam_role.codepipeline_service_role.name
  policy = data.aws_iam_policy_document.code_policy_document.json
}



# Allows the CloudWatch event to assume roles
resource "aws_iam_role" "cloudwatch_ci_role" {
  name_prefix = "${var.macro_project_name}-cloudwatch-ci"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}
data "aws_iam_policy_document" "cloudwatch_ci_iam_policy" {
  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
    resources = [
      aws_codepipeline.pipeline.arn
    ]
  }
}
resource "aws_iam_policy" "cloudwatch_ci_iam_policy" {
  name_prefix = "${var.macro_project_name}-cloudwatch-ci-"
  policy      = data.aws_iam_policy_document.cloudwatch_ci_iam_policy.json
}
resource "aws_iam_role_policy_attachment" "cloudwatch_ci_iam" {
  policy_arn = aws_iam_policy.cloudwatch_ci_iam_policy.arn
  role       = aws_iam_role.cloudwatch_ci_role.name
}