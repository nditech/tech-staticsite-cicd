## Terraform templates explanation

Both pipelines (with and without webhook) follow this logic:

- Create roles and policies in AWS.
- Create resources in AWS.
- Import secrets/keys/tokens from a `.tfvars` file.
- Create a CodePipeline using all the resources and roles.

Since we're using file `./pipeline-webhook.tf`, the pipleline without webhook is saved in `./test/pipeline.tf.stable` with a different extension than `.tf` to make sure terraform won't execute it.

## Working with terraform

- Running terraform in automation, using `terraform plan` and `terraform apply`, see [here](https://learn.hashicorp.com/terraform/development/running-terraform-in-automation).
- Use input variables, read [HashiCorp's guide](https://learn.hashicorp.com/terraform/getting-started/variables.html).
- For AWS references, use [HashiCorp's syntax](https://www.terraform.io/docs/providers/aws/#).

### Examples

- [AWS CodePipeline with webhook](https://www.terraform.io/docs/providers/aws/r/codepipeline_webhook.html).
