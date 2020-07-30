# SSM Configuration

The purpose of this terraform module is to provide a mechanism for pre-populating the SSM Paramater Store prior to applying some of the build pipelines such as crown-marketplace. This creates SSM Parameters, some with suitable values, others just as placeholders, for the mandatory paramaters so that the application can be deployed and started.

This module is completely optional and is typically only required for testing in a new AWS account and is simply here to "get things going".

As such there is no garantee that all the necessary parameters are present or have values that work, for example all keys have been given the value "redacted" and so will not work.
