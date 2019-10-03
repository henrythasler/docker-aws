locals {
  project = "postgis-server"
}


resource "aws_ecr_repository" "postgis_server_ecr_repository" {
  name = "${local.project}"
}


resource "aws_iam_policy" "postgis_server_policy" {
  name = "CodeBuildBasePolicy-${local.project}-${var.region}"
  description = "Policy to build ${local.project} in ${var.region}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:eu-central-1:324094553422:log-group:/aws/codebuild/${local.project}",
                "arn:aws:logs:eu-central-1:324094553422:log-group:/aws/codebuild/${local.project}:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-${var.region}-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        }
    ]
}
EOF
}




resource "aws_iam_role_policy_attachment" "postgis_server_policy_attachment" {
  role       = "${aws_iam_role.codebuild_worker_auto_role.name}"
  policy_arn = "${aws_iam_policy.postgis_server_policy.arn}"
}



resource "aws_codebuild_project" "postgis_server_build_project" {
  name          = "${local.project}"
  description   = "builds ${local.project}"
  build_timeout = "60"
  service_role  = "${aws_iam_role.codebuild_worker_auto_role.arn}"
  badge_enabled = true

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "${var.region}"
    }

    environment_variable {
      name  = "REPOSITORY_URI"
      value = "${aws_ecr_repository.postgis_server_ecr_repository.repository_url}"
    }

    environment_variable {
      name  = "IMAGE_NAME"
      value = "${local.project}"
    }
  }

  source {
    type            = "GITHUB"
    location        = "${var.git_repository}"
    git_clone_depth = 1
    buildspec       = "${local.project}/buildspec.yml"
  }
}


resource "aws_codebuild_webhook" "postgis_server_hook" {
  project_name = "${aws_codebuild_project.postgis_server_build_project.name}"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "${local.project}"
    }
  }
}

output "badge_url" {
  value = "${aws_codebuild_project.postgis_server_build_project.badge_url}"
}

