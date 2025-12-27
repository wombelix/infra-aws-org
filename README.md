<!--
SPDX-FileCopyrightText: 2025 Dominik Wombacher <dominik@wombacher.cc>

SPDX-License-Identifier: MIT-0
-->

# Infrastructure AWS Organizations

[![REUSE status](https://api.reuse.software/badge/git.sr.ht/~wombelix/infra-aws-org)](https://api.reuse.software/info/git.sr.ht/~wombelix/infra-aws-org)
[![builds.sr.ht status](https://builds.sr.ht/~wombelix/infra-aws-org.svg)](https://builds.sr.ht/~wombelix/infra-aws-org?)

## Table of Contents

* [Usage](#usage)
* [Source](#source)
* [Contribute](#contribute)
* [License](#license)

## Usage

### Prerequisites

* [AWS CLI](https://aws.amazon.com/cli/)
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
[git.sr.ht/~wombelix/infra-aws-org](https://git.sr.ht/~wombelix/infra-aws-org)

Mirrors are available on
[Codeberg](https://codeberg.org/wombelix/infra-aws-org),
[Gitlab](https://gitlab.com/wombelix/infra-aws-org)
and
[GitHub](https://github.com/wombelix/infra-aws-org).

## Contribute

Please don't hesitate to provide Feedback,
open an Issue or create a Pull / Merge Request.

Just pick the workflow or platform you prefer and are most comfortable with.

Feedback, bug reports or patches to my sr.ht list
[~wombelix/inbox@lists.sr.ht](https://lists.sr.ht/~wombelix/inbox) or via
[Email and Instant Messaging](https://dominik.wombacher.cc/pages/contact.html)
are also always welcome.

## License

Unless otherwise stated: `MIT-0`

All files contain license information either as
`header comment` or `corresponding .license` file.

[REUSE](https://reuse.software) from the [FSFE](https://fsfe.org/)
implemented to verify license and copyright compliance.
