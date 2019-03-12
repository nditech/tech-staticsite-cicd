# Terraform template provisions AWS infrastructure for the pipeline.
# In test.
# Able to provision infrastructure but not with a role for another AWS account.

# Input variables
variable "aws_region" {
    type = "string"
    default = "us-east-1"
}

variable "pipeline_name" {
    type = "string"
    default = "static-website-terraform"
}

variable "github_username" {
    type = "string"
    default = "nditech"
}

variable "github_token" {
    type = "string"
}

variable "github_repo" {
    type = "string"
}

provider "aws" {
    region = "${var.aws_region}"
    # assume_role {
    #     role_arn = "arn:aws:iam::216275992072:role/admin"
    #     profile = "default"
    # }
}

# CodePipeline resources
resource "aws_s3_bucket" "build_artifact_bucket" {
    bucket = "${var.pipeline_name}-artifact-bucket"
    acl = "private"
}

data "aws_iam_policy_document" "codepipeline_assume_policy" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["codepipeline.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "codepipeline_role" {
    name = "${var.pipeline_name}-codepipeline-role"
    assume_role_policy = "${data.aws_iam_policy_document.codepipeline_assume_policy.json}"
}

# CodePipeline policy needed to use CodeCommit and CodeBuild
resource "aws_iam_role_policy" "attach_codepipeline_policy" {
    name = "${var.pipeline_name}-codepipeline-policy"
    role = "${aws_iam_role.codepipeline_role.id}"

    policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning",
                "s3:PutObject"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "cloudwatch:*",
                "sns:*",
                "sqs:*",
                "iam:PassRole"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

# CodeBuild IAM Permissions
resource "aws_iam_role" "codebuild_assume_role" {
    name = "${var.pipeline_name}-codebuild-role"

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

resource "aws_iam_role_policy" "codebuild_policy" {
    name = "${var.pipeline_name}-codebuild-policy"
    role = "${aws_iam_role.codebuild_assume_role.id}"

    policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketVersioning"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Resource": [
                "${aws_codebuild_project.build_project.id}"
            ],
            "Action": [
                "codebuild:*"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        }
    ]
}
POLICY
}

# CodeBuild Section for the Package stage
resource "aws_codebuild_project" "build_project" {
    name = "${var.pipeline_name}-build"
    description = "The CodeBuild project for ${var.pipeline_name}"
    service_role = "${aws_iam_role.codebuild_assume_role.arn}"
    build_timeout = "60"

    artifacts {
        type = "CODEPIPELINE"
    }

    environment {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/nodejs:10.14.1"
        type = "LINUX_CONTAINER"
    }

    source {
        type = "CODEPIPELINE"
        buildspec = "buildspec.yml"
    }
}

# Full CodePipeline
resource "aws_codepipeline" "codepipeline" {
    name = "${var.pipeline_name}-codepipeline"
    role_arn = "${aws_iam_role.codepipeline_role.arn}"

    artifact_store = {
        location = "${aws_s3_bucket.build_artifact_bucket.bucket}"
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
            name = "Source"
            category = "Source"
            owner = "ThirdParty"
            provider = "GitHub"
            version = "1"
            output_artifacts = ["SourceArtifact"]

            configuration {
                Owner = "${var.github_username}"
                OAuthToken = "${var.github_token}"
                Repo = "${var.github_repo}"
                Branch = "master"
                PollForSourceChanges = "true"
            }
        }
    }

    stage {
        name = "Build"

        action {
            name = "Build"
            category = "Build"
            owner = "AWS"
            provider = "CodeBuild"
            input_artifacts = ["SourceArtifact"]
            output_artifacts = ["OutputArtifact"]
            version = "1"

            configuration {
                ProjectName = "${aws_codebuild_project.build_project.name}"
            }
        }
    }

    stage {
        name = "Deploy"

        action {
            name = "Deploy"
            category = "Deploy"
            owner = "AWS"
            provider = "S3"
            input_artifacts = ["OutputArtifact"]
            version = "1"

            configuration {
                BucketName = "${var.pipeline_name}-artifact-bucket"
                Extract = "true"
            }
        }
    }
}
