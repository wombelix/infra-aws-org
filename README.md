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

A one-time manual setup is required to create the IAM role that
CloudFormation will use for deployments.

1. Run the bootstrap script with permissions to create IAM Roles
   and Policies in your AWS Organizations Management Account:
   `./create-cfn-iam-role.sh`

1. Copy the output **Role ARN**. later needed when configuring
   the CloudFormation Stack.

Manually create a CloudFormation stack with the **Sync from Git**
option in the AWS console. Use the **Role ARN** from the script
output as the `IAM execution role`. Has to point to the repo mirror
on GitHub and to use `cfn-stack.yaml` as entrypoint.

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

Unless otherwise stated: `MIT`

All files contain license information either as
`header comment` or `corresponding .license` file.

[REUSE](https://reuse.software) from the [FSFE](https://fsfe.org/)
implemented to verify license and copyright compliance.
