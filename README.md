# TF DOCS
<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.14 |
| aws | >= 3.20.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.20.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_key | AWS access key | `string` | n/a | yes |
| repository\_names | Alumni database frontend/backend ECR repository name | `map(any)` | n/a | yes |
| secret\_key | AWS secret key | `string` | n/a | yes |

## Outputs

No output.

<!--- END_TF_DOCS --->
