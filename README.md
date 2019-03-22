<h1 align="center">
  <a href="https://www.ndi.org/"><img src="https://www.ndi.org/sites/all/themes/ndi/images/NDI_logo_svg.svg" alt="NDI Logo" width="200"></a>
</h1>

<h1 align="center">
  CI/CD Implementation for Static Website Generator
</h1>

<p align="center">
  <a href="./LICENSE">
    <img src="https://img.shields.io/badge/license-GPL-red.svg" alt="License"/>
  </a>
</p>

<p align="center">
  <a href="#documentation">Documentation</a> - 
  <a href="#license">License</a> - 
  <a href="#authors">Author(s)</a>
</p>

## Documentation

This documentation assumes that you're running a UNIX machine (Linux or Mac) and you already have an AWS account. If you're running a Windows machine, the commands may be different.

### Table of Contents

1. [Intro](#intro)
1. [Demo](#demo)
1. [Installation](#installation)
1. [Diagnosis](#diagnosis)
1. [Contribution](#contribution)

## Intro

This is a demonstration of NDI Tech's CI/CD implementation for generated static websites. This website is built with [Hugo](https://gohugo.io/). The deployment of the website is automated by [AWS CodePipeline](https://aws.amazon.com/codepipeline/). The AWS infrastructure is provisioned by a [terraform](https://www.terraform.io/) or an AWS [CloudFormation](https://aws.amazon.com/cloudformation/) template. You can use any other framework to build your website (React, Angular, etc.) and other infrastructure-as-code template (like AWS CloudFormation) to provision your infrastructure.

The benefit of using a framework like Hugo is your team can quickly create a static website with plenty of themes to choose from.

AWS CodePipeline automates the workflow for developing, testing and deploying the website, in this case, to an S3 bucket. It works with any repository on GitHub (or the equivalent of your cloud provider), and any framework that crates a `build` or `public` folder contains all `html`, `css` and `js` files.

Terraform automates the process of setting up your AWS Codepipeline. Terrafrom works with other cloud providers, not just with AWS.

- Read more about how to manually set up an AWS CodePipeline and detailed explanation of a `buildspec.yml` file [here](./docs/aws/codepipeline.md). 

## Demo

- [Working demo in an S3 bucket](http://static-website-terraform-artifact-bucket.s3-website-us-east-1.amazonaws.com/).

## Installation

Make sure you have on your machine:

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [Hugo](https://gohugo.io/getting-started/installing/)

Clone this repository to your local machine (using SSH):
```
$ git clone git@github.com:nditech/tech-staticsite-cicd.git
$ cd tech-staticsite-cicd
```

### Deploy the stack with Terraform

Make sure you have on your machine:
- [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)

Copy the output of the command below and use it as your webhook secret. You can use another command or just make your own secret from a string of random characters. It's recommended to to pull the webhook secret from the environment or something like SSM Parameter Store.
```
ruby -rsecurerandom -e 'puts SecureRandom.hex(20)'
```
Create a `secret.tfvars` that looks like this:
```
github_repo = "<YOUR-REPO-NAME>"
github_token= "<YOUR-GITHUB-TOKEN>
webhook_secret = "<YOUR-WEBHOOK-SECRET>"
```
Then run these:
```
$ terraform init -input=false
$ terraform plan -var-file="secret.tfvars" -out=tfplan -input=false 
$ terraform apply -input=false tfplan
```
You should have your AWS infrastructure ready with a public website hosted in an S3 bucket.

### Deploy the stack with AWS CloudFormation

> NOTE: Currently, only template `./test/s3.json.template` works.

Use the `.json.template` files, remove the `.template` extension. Currently, they're inside `./test`.

- If you use AWS Console, just copy and paste the content of the `.json` file into CloudfFormation, remember to choose tab **Template**, validate the stack then create it. For more details, check [AWS Documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-guide.html).

- If you use AWS CLI, run this command where the template file is:
    ```
    $ aws cloudformation create-stack --stack-name <NAME-OF-YOUR-STACK> --template-body file://<TEMPLATE-NAME>.json --parameters <OPTIONAL-PARAMETERS>
    ```

## Diagnosis

- [Generate your GitHub token](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line).
- [Create and secure your GitHub webhook](https://developer.github.com/webhooks/securing/).
- [Manually set up AWS CodePipeline](./docs/aws/codepipeline.md).
- [Configure terraform file](./docs/terraform/README.md).
- [Configure a Hugo's template](./docs/hugo/README.md).
- Error:
    ```
    Error: Error applying plan:
    1 error(s) occurred:
    * aws_codepipeline_webhook.codepipeline: 1 error(s) occurred:
    * aws_codepipeline_webhook.codepipeline: doesn't support update
    ```
    That means terraform webhook option doesn't support update, doesn't mean it did not deploy the infrastructure. Check your AWS CodePipeline to make sure your pipeline works.

## Contribution

- Please read our [Code Commits Guide](https://github.com/nditech/git-styleguide) and [Documentation Guide](https://github.com/nditech/standardized-README).
- We also follow Google's [Javascript Style Guide](https://google.github.io/styleguide/jsguide.html) and Airbnb's [React Style Guide](https://github.com/airbnb/javascript/tree/master/react).
- Do your own unit test before committing code.

## License

[GNU General Public License v3.0](./LICENSE)

## Author(s)

Theme modified by Noble Ackerson from [Elate theme](https://freehtml5.co/) which was ported to Hugo by [Pieter Saey](http://saey55.gitlab.io/pietercv).

- <b>Noble Ackerson</b>
    > nackerson@ndi.org &nbsp;&middot;&nbsp;
    > [LinkedIn](https://www.linkedin.com/in/noblea)

- <b>Viet Nguyen</b>
    > vnguyen@ndi.org &nbsp;&middot;&nbsp;
    > [LinkedIn](https://www.linkedin.com/in/nguyendviet)

**[⬆ back to top](#documentation)**
