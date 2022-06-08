# Sym Lambda Adapter Quickstart

A starter workflow to integrate Sym with an API using an AWS Lambda adapter.

## Tutorial

TBD

## Data Flow

When an End-User approves a Lambda-based escalation request, the Sym Platform does the following:

1. Assumes your [Runtime Connector](https://docs.symops.com/docs/runtime-connector) IAM role. This role lives in your AWS account, and has access to tagged secrets within your AWS Secrets Manager instance.
2. The Sym Runtime then assumes roles _again_ - this time your [Lambda Connector](https://docs.symops.com/docs/lambda-connector) IAM role. This role is trusted by the Runtime Connector and can be in the same AWS account or a different AWS account within your infrastructure.
3. Using the Lambda Connector role, the runtime invokes a Lambda function to finish the escalation or de-escalation

### Security Considerations

Sym's Runtime Connector IAM Role has a trust relationship with Sym's production AWS account. This trust relationship allows the Sym platform to securely assume your Runtime Connector IAM role without a password. This is called a "role chaining" type of trust relationship.

The RuntimeConnector module ensures that we use an [external id](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html) when assuming your IAM Role per AWS best practices.

![Data Flow](docs/SymDataFlow.jpg)

## About Sym

This workflow is just one example of how [Sym Implementers](https://docs.symops.com/docs/deploy-sym-platform) use the [Sym SDK](https://docs.symops.com/docs) to create [Sym Flows](https://docs.symops.com/docs/flows) that use the [Sym Approval](https://docs.symops.com/docs/sym-approval) Template.
