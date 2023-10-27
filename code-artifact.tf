# resource "aws_codeartifact_domain" "yp" {
#   domain         = var.codeartifact_domain_name
#   encryption_key = aws_kms_key.cmk_key.arn
# }

# resource "aws_codeartifact_repository" "yp_repo" {
#   repository = var.codeartifact_repo_name
#   domain     = aws_codeartifact_domain.yp.domain

#   upstream {
#     repository_name = aws_codeartifact_repository.node_repo.repository
#   }
# }


# resource "aws_codeartifact_repository" "node_repo" {
#   repository = "npm-public"
#   domain     = aws_codeartifact_domain.yp.domain

#   external_connections {
#     external_connection_name = "public:npmjs"
#   }
# }