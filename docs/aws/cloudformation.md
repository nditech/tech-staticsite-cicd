## AWS CloudFormation template explanation

- Before working with CloudFormation template, read AWS Docs: [CloudFormation Template Anatomy](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html).

### For the example in this repository:

- The stack uses webhook for GitHub repository.
- Edit `"Default"` values in `"Parameters": {...}` for specific project or use `--parameter-overrides` as described [here](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/deploy/index.html).
- The token is saved in **AWS Systems Manager Parameter Store**. Learn more about SSM [here](https://aws.amazon.com/blogs/mt/using-aws-systems-manager-parameter-store-secure-string-parameters-in-aws-cloudformation-templates/).
    ```
    "GitHubToken": {
        "NoEcho": true,
        "Type": "String",
        "Default": "{{resolve:ssm:staticSiteCICDGitHubToken:1}}",
        "Description": "GitHub Token stored in AWS Systems Manager Parameter Store."
    },
    ```
- The template uses build commands instead of a `buildspec.yml` file as another example of how you could run the build commands.
    ```
    "CodeBuildDeploySite": {
        ...
            "Source": {
                "Type": "CODEPIPELINE",
                "BuildSpec": {
                    "Fn::Sub": "version: 0.2\nphases:\n  pre_build:\n    commands:\n      - aws s3 rm s3://${SiteBucketName} --recursive \n  build:\n    commands:\n      - mkdir build-output \n      - find . -type d -name public -exec cp -R {} build-output \\; \n      - find . -mindepth 1 -name build-output -prune -o -exec rm -rf {} + \n  post_build:\n    commands:\n      - mv build-output/**/* ./ \n      - mv build-output/* ./ \n      - rm -R build-output \nartifacts:\n  files:\n    - '**/*'\n  name: $(AWS_REGION)-$(date +%Y-%m-%d) \n"
                }
            },
            "TimeoutInMinutes": 10
        }
    },
    ```
    This looks ugly but the beauty of it is you can pass in more variables like `${SiteBucketName}` above. That way, you can pass in any bucketname as part of the stack. **You can look at the nice version of the buildspec in the Console: CodeBuild > Build projects > YOUR PROJECT NAME > Edit Buildspec**.
    
    To use a `buildspec.yml` file, remove the `"BuildSpec"` part and make sure the buildspec has the right commands for your pipeline. Learn more about buildspec environtment variables [here](https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-env-vars.html).
- Before deleting stack, remember to empty both `SiteBucket` and `PipelineBucket` S3 buckets.
