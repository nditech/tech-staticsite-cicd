# Terraform template provisions AWS infrastructure for the pipeline.
# Run these commands from the terminal:
# $ terraform plan -var-file="secret.tfvars" -out=tfplan -input=false
# $ terraform apply -input=false tfplan

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

variable "webhook_secret" {
    type = "string"
}

variable "github_repo" {
    type = "string"
}

provider "aws" {
    region = "${var.aws_region}"
}

# Configure the GitHub Provider
provider "github" {
    token = "${var.github_token}"
    organization = "${var.github_username}"
}

# CodePipeline resources
# Create a bucket for public hosting
resource "aws_s3_bucket" "build_artifact_bucket" {
    bucket = "${var.pipeline_name}-artifact-bucket"
    acl    = "public-read"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.pipeline_name}-artifact-bucket/*"
        }
    ]
}
EOF

    website {
        index_document = "index.html"
        error_document = "error.html"

        routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
    }
}

# Create a json file for CodePipeline's policy
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

# Create a role for CodePipeline
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
                "s3:PutObject",
                "s3:ListBucket",
                "s3:DeleteObject"
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

# Create CodeBuild role
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

# Create CodeBuild policy
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
                "s3:GetBucketVersioning",
                "s3:ListBucket",
                "s3:DeleteObject"
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

# Create CodeBuild project
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

# Create CodePipeline
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
                # PollForSourceChanges = "true"
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

# Add webhook to pipeline
resource "aws_codepipeline_webhook" "codepipeline" {
    name            = "${var.pipeline_name}-codepipeline-webhook"
    authentication  = "GITHUB_HMAC"
    target_action   = "Source"
    target_pipeline = "${aws_codepipeline.codepipeline.name}"

    authentication_configuration {
        secret_token = "${var.webhook_secret}"
    }

    filter {
        json_path    = "$.ref"
        match_equals = "refs/heads/{Branch}"
    }
}

# Wire the CodePipeline webhook into a GitHub repository.
resource "github_repository_webhook" "codepipeline" {
    repository = "${var.github_repo}"

    name = "web"

    configuration {
        url          = "${aws_codepipeline_webhook.codepipeline.url}"
        content_type = "form"
        insecure_ssl = true
        secret       = "${var.webhook_secret}"
    }

    events = ["push"]
}
