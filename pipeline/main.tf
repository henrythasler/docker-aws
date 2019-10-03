provider "aws" {
  version = "~> 2.16"
  profile = "default"
  region  = "${var.region}"
}

# this is where we store the terraform-state.
# Change at least `bucket` to match your account's environment.
# Remove the whole terraform-entry to use a local state.
terraform {
  backend "s3" {
    bucket         = "terraform-state-0000"
    key            = "docker-aws/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

resource "aws_iam_role" "codebuild_worker_auto_role" {
  name               = "codebuild-worker-auto-role"
  description        = "Role to build images"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryPowerUser" {
    role       = "${aws_iam_role.codebuild_worker_auto_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}