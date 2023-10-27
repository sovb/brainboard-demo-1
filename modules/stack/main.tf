resource "aws_ecr_repository" "destination_ecr_repository" {
  name = var.repository_name

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }
}

resource "aws_ecr_lifecycle_policy" "keep_last_five_tagged_images" {
  repository = aws_ecr_repository.destination_ecr_repository.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last ${var.lifecycle_image_count} images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": ${var.lifecycle_image_count}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_codecommit_repository" "repo" {
  repository_name = var.repository_name
  description     = "This stores the ${var.repository_name} repository, within the ${var.project_name} project"

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_codebuild_project" "build_project" {

  name           = "${var.repository_name}-build-project"
  description    = "This project builds the ${var.repository_name} repository in project ${var.project_name}"
  service_role   = aws_iam_role.codebuild_service_role.arn
  encryption_key = var.kms_key_arn

  artifacts {
    type     = "S3"
    location = var.artifacts_bucket

  }

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "AWS_ACCOUNT"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "CODEARTIFACT_DOMAIN_NAME"
      value = var.codeartifact_domain_name
    }
    environment_variable {
      name  = "CODEARTIFACT_REPOSITORY_NAME"
      value = var.codeartifact_repository_name
    }
    environment_variable {
      name  = "ECR_URL"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
    }
    environment_variable {
      name  = "CONTAINER_REPOSITORY_URL"
      value = aws_ecr_repository.destination_ecr_repository.repository_url
    }
    environment_variable { ##CHECKER AVEC YP LA LOGIQUE DES TAGS
      name  = "TAG_NAME"
      value = "latest"
    }
  }

  cache {
    type     = "S3"
    location = var.artifacts_bucket
  }

  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.repo.clone_url_http
    buildspec       = "build/buildspec.yml"
    git_clone_depth = 1


    git_submodules_config {
      fetch_submodules = true
    }

  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.private_subnet_ids
    security_group_ids = var.security_group_ids
  }
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.repository_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_service_role.arn

  artifact_store {
    type     = "S3"
    location = var.artifacts_bucket
    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "ArtifactSourceCode"
      namespace        = "SourceVariables"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceCodeArtifact"]

      configuration = {
        RepositoryName       = aws_codecommit_repository.repo.repository_name
        BranchName           = "develop"
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
        PollForSourceChanges = "false"
      }
    }
  }



  stage {

    name = "${var.repository_name}-build"

    action {
      name = "build"

      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceCodeArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      run_order        = 1
      configuration = {
        ProjectName = aws_codebuild_project.build_project.arn
        EnvironmentVariables = jsonencode([{
          "name"  = "SOURCE_BRANCH_NAME"
          "type"  = "PLAINTEXT"
          "value" = "#{SourceVariables.BranchName}"
        }])

      }
    }
  }

}

resource "aws_cloudwatch_event_rule" "event_rule_trigger" {
  name          = "${var.repository_name}-develop-branch-ci-trigger"
  description   = "Rule to trigger an image build when CodeCommit repository is updated"
  event_pattern = <<PATTERN
 {
  "source": ["aws.codecommit"],
  "detail-type": ["CodeCommit Repository State Change"],
  "resources": ["${aws_codecommit_repository.repo.arn}"],
  "detail": {
    "referenceType": [
        "branch"
    ],
    "referenceName": [
        "master", "develop", "release/*", "feature/*"
    ]
  }
}
PATTERN
}
resource "aws_cloudwatch_event_target" "event_rule_trigger_target" {
  arn      = aws_codepipeline.pipeline.arn
  rule     = aws_cloudwatch_event_rule.event_rule_trigger.id
  role_arn = aws_iam_role.cloudwatch_ci_role.arn
}