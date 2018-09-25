# Bootstrap

This section exists in order to setup some pre-requisites within the AWS account for storing the state of the infrastructure.
By default, state will be stored locally on the developer machine - however, this isn't suitable if multiple people are working within the same environment.

Running terraform `init` and then `apply` within this directory will:

 * Create an S3 bucket that all of the infrastructure state will be stored within
 * Create a DynamoDB table that will handle locking of the state between multiple users
 * Automatically generate `backend.tf` files within the other component directories, that will contain appropriate configuration

NOTE: This assumes a certain directory layout and will need modification as the structure changes.
It is purely a starter-for-ten with regards to simplifying the configuration.