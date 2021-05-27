# TF DOCS
<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.14 |
| azurerm | 2.42.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | 2.42.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| random | Brief description of varaible usage | `string` | `"random"` | no |

## Outputs

| Name | Description |
|------|-------------|
| az\_resource\_group\_name | n/a |
| id | n/a |

<!--- END_TF_DOCS --->

# terraform base template
### base template for a terraform module (sample terraform config files in /examples)

    .
    ├── main.tf                                     # main set of configuration for your module, you can also create other configuration files and organize them however makes sense for your project (see the aws example in /examples)
    ├── locals.tf                                   # contain the local definitions for your module
    ├── variables.tf                                # contain the variable definitions for your module
    ├── data.tf                                     # contain the data definitions for your module
    ├── outputs.tf                                  # contain the output definitions for your module
    ├── providers.tf                                # contain the provider definitions for your module
    ├── versions.tf                                 # contain the version definitions for your providers and terraform  
    ├── *.auto.tfvars or terraform.tfvars           # contain values to populate your variables.tf file        
    └── README.md                                   # contain detailed documentation of your module, including usage, required input variables, outputs, etc
    └── .gitignore                                  # contain files that should not be included in source control
    └── .terraform.lock.hcl                         # dependency lock file that tracks provider dependencies

### always run "terraform fmt" after making changes to maintain consistent styling of terraform code
