# Routing

This folder contains a [Terraform](https://www.terraform.io/) module to create infrastructure associated with routing requests through to an individual Service.

## How do you use this module?

This folder defines a [Terraform module](https://www.terraform.io/docs/modules/usage.html), which you can use in your
code by adding a `module` configuration and setting its `source` parameter to URL of this folder:

```hcl
module "routing" {
  source = "github.com/Crown-Commercial-Service/CMpDevEnvironment//terraform/modules/routing?ref=master"

  # Specify a type (api/app) to help tagging 
  type     = "app"

  # Specify a name to help tagging and visibility.
  name     = "app1"

  # Specify a (sub)domain that the rule and target group should be based upon.
  domain   = "apps.example.com"

  # Specify the hostname that the rule and target group should point at
  hostname = "application"

# Setting this to true will generate an additional rule for *.domain to this application or container.
  catch_all = false

  # Specify the port that the rule will apply to.
  port     = "80"

  # Specify the protocol that will used, to determine if certificates are provisioned (https only) 
  protocol = "http"

  # ... See variables.tf for any other parameters you may define
}
```

Note the following parameters:

* `source`: Use this parameter to specify the URL of the build module. The double slash (`//`) is intentional 
  and required. Terraform uses it to specify subfolders within a Git repo (see [module 
  sources](https://www.terraform.io/docs/modules/sources.html)). The `ref` parameter specifies a specific Git tag in 
  this repo. That way, instead of using the latest version of this module from the `master` branch, which 
  will change every time you run Terraform, you're using a fixed version of the repo.

You can find any other parameters in [variables.tf](variables.tf).

Check out the [component module](https://github.com/Crown-Commercial-Service/CMpDevEnvironment/blob/production/terraform/modules/component/main.tf) for fully-working sample code. 

## What's included in this module?

This module creates an `AWS Route 53 subdomain` as specified, an `AWS Application Load Balancer Listener Rule`, that will route requests for this domain through to a newly created `Target Group` that can be passed to a Service or other infrastructure.
