# adapter-lambda

## Building

You'll need to build the handler zip so that Terraform can complete provisioning.

```bash
$ cd handler
$ ./build.sh
```

## Deploying

### Password Configuration

Once you run a `terraform apply`, you need to configure the client secrets that the handler should use to auth with your API. The handler looks up your secret in an [AWS Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) Parameter. The Parameter is named based on your Lambda function name, like `/symops.com/FUNCTION_NAME/API_KEY`. You can set the value from the console or from the command line:

```bash
$ aws ssm put-parameter \
  --name /symops.com/FUNCTION_NAME/API_KEY \
  --value "${API_KEY}" \
  --type SecureString \
  --overwrite
```

### Updating the Implementation

Once you've run your Terraform pipeline, you can update the function code using the [`build.sh`](handler/build.sh) by specifying an `environment` argument:

```bash
$ cd handler
$ ./build.sh -e prod
```

## Local testing

You can iterate on your handler function locally!

1. Copy [`env.example`](handler/test/env.example) to `.env` and then `source` it into your shell
2. Run `pip install -r requirements.txt`
3. Run `cat test/escalate.json | python handler.py` to run your handler
