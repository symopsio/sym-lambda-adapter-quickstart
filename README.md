# Sym Lambda Adapter Quickstart

A starter workflow to integrate Sym with an API using an AWS Lambda adapter.

## Tutorial

You can follow along with the [Postgres Quickstart](https://postgres.tutorials.symops.com) which has good instructions for working with this type of flow.

### API Configuration

For the Adapter lambda, you need to configure `api_targets` in `terraform.tfvars`. This is a listing of IDs and Labels that users should request access to.

## Data Flow

When an End-User approves a Lambda-based escalation request, the Sym Platform does the following:

1. Assumes your [Runtime Connector](https://docs.symops.com/docs/runtime-connector) IAM role. This role lives in your AWS account, and has access to tagged secrets within your AWS Secrets Manager instance.
2. The Sym Runtime then assumes roles _again_ - this time your [Lambda Connector](https://docs.symops.com/docs/lambda-connector) IAM role. This role is trusted by the Runtime Connector and can be in the same AWS account or a different AWS account within your infrastructure.
3. Using the Lambda Connector role, the runtime invokes a Lambda function to finish the escalation or de-escalation

### Security Considerations

Sym's Runtime Connector IAM Role has a trust relationship with Sym's production AWS account. This trust relationship allows the Sym platform to securely assume your Runtime Connector IAM role without a password. This is called a "role chaining" type of trust relationship.

The RuntimeConnector module ensures that we use an [external id](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html) when assuming your IAM Role per AWS best practices.

![Data Flow](docs/SymDataFlow.jpg)

## Repo layout

Your engineers provision resources in both AWS and Sym. You can mix and match your Terraform resources in whatever way works best for your organization. Our default setup puts shared configurations in the `sym-runtime` module and makes it easy to add new modules for specific Flows.

![Provisioning Flow](docs/SymProvisioningFlow.jpg)

### environments

This repo contains both Terraform environments and modules. Environments represent actual provisioned resources in AWS and Sym. Modules are reusable components that you can parameterize and deploy to multiple environments.

The [prod environment](environments/prod) is where we can iterate on the access workflow logic and test with initial users. Once we've got a setup that we like, we can set up a sandbox environment that we'll use for safe future iteration.
### sym-runtime module

The [`sym-runtime`](modules/sym-runtime) creates a shared Runtime that executes all your Flows.

### adapter-lambda module

The [`adapter-lambda`](modules/adapter-lambda) module creates an AWS Lambda function that your workflow invokes to hit your API.

Refer to the [`README`](modules/adapter-lambda/README.md) for deployment and configuration details.

### api-flow module

The [`api-flow`](modules/api-flow) module defines the workflow that your engineers will use to invoke your adapter Lambda function.

## About Sym

This workflow is just one example of how [Sym Implementers](https://docs.symops.com/docs/deploy-sym-platform) use the [Sym SDK](https://docs.symops.com/docs) to create [Sym Flows](https://docs.symops.com/docs/flows) that use the [Sym Approval](https://docs.symops.com/docs/sym-approval) Template.
