# shared

Provisions infrastructure shared by the other groups

## Terraform variables

| Name            | Description                                                 | Default         | Example          | Notes        |
| --------------- | ----------------------------------------------------------- | --------------- | ---------------- | ------------ |
| account_name    | The name of the AWS account we're using                     | `-`             | `development`    | -            |
| environment     | The environment name to be used when creating AWS resources | `-`             | `my_environment` | -            |
| region          | The AWS region in which resources will be administered      | `-`             | `eu-west-2`      | -            |
| repository_name | The name of the repository in which we're operating         | `logging-stack` | `-`              | `deprecated` |
| service         | The service name to be used when creating AWS resources     | `logging`       | `-`              | -            |
| ssh_public_key  | The SSH public key used to provision pem keys               | `-`             | `ssh-rsa .....`  | -            |
| team            | The team responsible for administering the instance         | `-`             | `platform`       | -            |
