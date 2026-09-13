<!--
SPDX-FileCopyrightText: 2025 Dominik Wombacher <dominik@wombacher.cc>

SPDX-License-Identifier: Apache-2.0
-->

# Infrastructure AWS Organizations

<!-- markdownlint-disable MD013 -->
[![REUSE status](https://api.reuse.software/badge/github.com/wombelix/infra-aws-org)](https://api.reuse.software/info/github.com/wombelix/infra-aws-org)
[![Mirror](https://github.com/wombelix/infra-aws-org/actions/workflows/mirror.yml/badge.svg)](https://github.com/wombelix/infra-aws-org/actions/workflows/mirror.yml)
<!-- markdownlint-enable MD013 -->

## Table of Contents

* [Usage](#usage)
* [Source](#source)
* [Contribute](#contribute)
* [License](#license)

## Usage

### Prerequisites

* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/)
* [Rain](https://github.com/aws-cloudformation/rain)
* [Task](https://taskfile.dev/)

### IAM Roles

The IAM roles for CloudFormation are managed in `cfn/iam-cfn-roles.yaml`.
Two roles exist:

* `CustomerServiceRoleForCloudformationInfraAWSOrg` -
  Used by CloudFormation to manage AWS Organizations resources
* `CustomerServiceRoleForCloudformationInfraAWSOrgGitSync` -
  Used by CodeConnections for Git sync

If these roles already exist in the account, import them into CloudFormation:

```bash
task iam-cfn-roles:import
```

If the roles don't exist yet, create them:

```bash
task iam-cfn-roles:deploy
```

For future updates, use `task iam-cfn-roles:deploy`.

Run `task` to list all available tasks.

### Git Sync Stacks

Create CloudFormation stacks with Sync from Git through the AWS console.
Use the Role ARN from `task iam-cfn-roles:deploy` output as IAM execution role.
Point to the repo mirror on GitHub and each `stack-deployment-X.yaml` file.
Create one stack per entry point file.

## Source

The primary location is:
[github.com/wombelix/infra-aws-org](https://github.com/wombelix/infra-aws-org)

Mirrors are available on
[Codeberg](https://codeberg.org/wombelix/infra-aws-org) and
[Gitlab](https://gitlab.com/wombelix/infra-aws-org).

## Contribute

Pick the platform you prefer and are most comfortable with.

Provide feedback, open an issue or create a pull / merge request.

## License

Unless otherwise stated: `Apache 2.0`

All files contain license information either as a
`header comment` or a `corresponding .license` file.

[REUSE](https://reuse.software) from the [FSFE](https://fsfe.org/)
is implemented to verify license and copyright compliance.
