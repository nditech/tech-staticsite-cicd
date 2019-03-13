# How to build a pipeline to automate deployment with GitHub, AWS CodeBuild and CodePipeline for static websites in S3

> Note: Make sure you have access to the services that you need.

## 1. Create a pipeline with CodePipeline

1. Go to `CodePipeline`, select `Create Pipeline`.
1. Pipeline settings:
    - Pipeline name: *your choice*
    - Service role: follow AWS description
    - Artifact store: follow AWS description.
1. Source:
    - Source provider: GitHub.
    - Click `Connect to GitHub`.
    - Login to your Github account.
    - Repository: pick the repository you want.
    - Branch: should not pick `master` for important projects. Instead, choose a `dev` or `prod` branch.
    - Change detection options: GitHub webhooks (recommended).
1. Build:
    - Build provider: AWS CodeBuild
    - Project name: follow AWS description.
        - Make sure the role in Project Environment > Service role has List and Write (DeleteObject) permissions. The default role for CodeBuild project doesn't have them.
        - Example of a codebuild role:
        ```
            {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Sid": "VisualEditor0",
                        "Effect": "Allow",
                        "Action": [
                            "s3:GetObject",
                            "s3:PutObject",
                            "logs:CreateLogStream",
                            "s3:ListBucket",
                            "s3:DeleteObject",
                            "logs:PutLogEvents",
                            "s3:GetObjectVersion"
                        ],
                        "Resource": [
                            "arn:aws:s3:::*",
                            "arn:aws:logs:us-east-1:216275992072:log-group:/aws/codebuild/static-sites",
                            "arn:aws:logs:us-east-1:216275992072:log-group:/aws/codebuild/static-sites:*"
                        ]
                    },
                    {
                        "Sid": "VisualEditor1",
                        "Effect": "Allow",
                        "Action": [
                            "s3:ListAllMyBuckets",
                            "s3:HeadBucket",
                            "logs:CreateLogGroup"
                        ],
                        "Resource": "*"
                    }
                ]
            }
        ```
1. Deploy:
    - Deploy provider: Amazon S3.
    - Check: Extract file before deploy.

## 2. Use CodeBuild

If in 1.4 you chose: `Create project`, then in `Create build project: Buildspec: Build specifications`, you selected `Use a buildspec file`, then you need to include a `buildspec.yml` file in the root folder of the repository in GitHub.

The `buildspec.yml` file should look like this:

```
version: 0.2

phases:
  pre_build:
    commands:
      - aws s3 rm s3://<YOUR-BUCKET-NAME> --recursive
  build:
    commands:
      - mkdir build-output
      - find . -type d -name public -exec cp -R {} build-output \;
      - find . -mindepth 1 -name build-output -prune -o -exec rm -rf {} +
  post_build:
    commands:
      - mv build-output/**/* ./
      - mv build-output/* ./
      - rm -R build-output
artifacts:
  files:
    - '**/*'
  name: $(AWS_REGION)-$(date +%Y-%m-%d) 
```

In words:
- In `pre_build` step:
    - Clean up (remove all objects) inside S3 bucket named `your-bucket`.
- In `build` step: 
    - Create a folder called `build-output` (you can name it whatever you want), then find a folder named `public` and copy everything in there to folder `build-output`.
    - Find a folder named `build-output` (in this case, go deep 1 level in the current folder), then remove everything else.
- In `post_build` step:
    - Move all files and folders inside folder `build-output` out to the root folder.
    - Remove folder `build-output`. At this point, the artifacts contain only files and folders were originally inside folder `public` in the GitHub repository that was used.
- Pass the artifacts to S3, extract everything.

This way, for any static site (its content is usually stored inside a folder called `build` or `public`), you can always get the result of the build regardless of the platform's folder structure (in some GitHub repositories, the `public`/`build` folder is nested inside other folders). Then, you put everything in that build folder into a designated S3 bucket, whilst keeping the structure of files and folders. That way, all relative paths will be kept intact.

An example of the `buildspec.yml` can be found [here](https://github.com/nditech/NDI-Demtools).
