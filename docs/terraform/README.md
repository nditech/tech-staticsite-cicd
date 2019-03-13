## Working with terraform

- Running terraform in automation, using `terraform plan` and `terraform apply`, see [here](https://learn.hashicorp.com/terraform/development/running-terraform-in-automation).
- Use input variables, read [HashiCorp's guide](https://learn.hashicorp.com/terraform/getting-started/variables.html).
- For AWS references, use [HashiCorp's syntax](https://www.terraform.io/docs/providers/aws/#).

### Examples

- [AWS CodePipeline with webhook](https://www.terraform.io/docs/providers/aws/r/codepipeline_webhook.html).
    Known issue for this approach:
    ```
    $ terraform plan -var-file="secret.tfvars" -out=tfplan -input=false 
    Error: provider.github: "organization": required field is not set
    Error: provider.github: "token": required field is not set
    ```