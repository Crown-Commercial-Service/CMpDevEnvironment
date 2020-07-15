# Providers

This folder contains a [Terraform](https://www.terraform.io/) module to centralise the provider versions and configuration for consistency across the various terraform projects and modeules in this repo

## How do you use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```hcl
module "providers" {
  source = "../../modules/providers"

# Specify the aws region, defaulting to eu-west-2 if not set
  region = "eu-west-2"  
}
```

## What's included in this module?

This module defines a standard set of providers used throughout the code, their versions and any default configuration required.  
