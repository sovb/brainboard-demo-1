# resource "aws_kms_key" "cmk_key" {
#   description = "${var.macro_project_name}-kms-key"
# }


# resource "aws_kms_alias" "cmk_key_alias" {
#   name          = "alias/${var.macro_project_name}-cmk-key"
#   target_key_id = aws_kms_key.cmk_key.key_id
# }


# data "aws_iam_policy_document" "key_policy_doc" {
#   statement {
#     sid = "Allow administration of the key"
#     actions = [
#       "kms:Create*",
#       "kms:Describe*",
#       "kms:Decrypt",
#       "kms:Enable*",
#       "kms:List*",
#       "kms:Put*",
#       "kms:Generate*",
#       "kms:Update*",
#       "kms:Revoke*",
#       "kms:Disable*",
#       "kms:Get*",
#       "kms:Delete*",
#       "kms:ScheduleKeyDeletion",
#       "kms:CancelKeyDeletion"
#     ]
#     resources = ["*"]
#     principals {
#       type        = "AWS"
#       identifiers = [data.aws_caller_identity.current.arn]
#     }
#   }

#   statement {
#     sid = "Allow project's role to use key "
#     actions = [
#       "kms:Encrypt",
#       "kms:Decrypt",
#       "kms:ReEncrypt*",
#       "kms:GenerateDataKey*",
#       "kms:DescribeKey"
#     ]
#     resources = ["*"]
#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#     }
#     condition {
#       test     = "StringLike"
#       variable = "aws:PrincipalArn"
#       values = [
#         "arn:aws:iam::${data.aws_caller_identity.current.account_id}:*/${var.macro_project_name}-*"
#       ]
#     }
#   }

#   #   statement {
#   #     sid = "Test"
#   #     actions = [
#   #       "kms:CreateGrant",
#   #       "kms:ListGrants",
#   #       "kms:RevokeGrant"
#   #     ]
#   #     resources = ["*"]
#   #     principals {
#   #       type        = "AWS"
#   #       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
#   #     }

#   #   }

# }

# resource "aws_kms_key_policy" "key_policy" {
#   key_id = aws_kms_key.cmk_key.id
#   policy = data.aws_iam_policy_document.key_policy_doc.json
# }