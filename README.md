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
Point to the repo mirror on GitHub and each `stack-deployment-X.yaml` file.
Create one stack per entry point file. The console asks for two roles:

* `CustomerServiceRoleForCloudformationInfraAWSOrgGitSync` -
  IAM role for Git sync
* `CustomerServiceRoleForCloudformationInfraAWSOrg` -
  IAM execution role

`task iam-cfn-roles:deploy` prints both ARNs. A deploy without changes prints
no ARNs. In that case, list them with:

```bash
aws cloudformation describe-stacks \
  --stack-name iam-cfn-roles \
  --region eu-central-1 \
  --query 'Stacks[0].Outputs[].[OutputKey,OutputValue]' \
  --output table \
  --no-cli-pager
```

### Stacks

* `stack-deployment-budget.yaml` - monthly cost budget, Cost Anomaly
  Detection and the SNS topic `Notifications` with an email subscription for
  their alerts
* `stack-deployment-iac.yaml` - GitHub OIDC provider and
  `OpenTofuRemoteBackendAccessRole` in the management account, plus the
  account vending parts below
* `stack-deployment-policies.yaml` - tag policy, AI services opt-out, chatbot
  policy and EC2 declarative policy on the root
* `stack-deployment-rcp.yaml` - RCPs on the root: secure transport,
  encryption, org-only access, confused deputy protection and approved OIDC
  providers only
* `stack-deployment-scp.yaml` - root SCP with EU regions only, root user
  limits and data lock-in denies, plus the Projects and Suspended OU SCPs
* `stack-deployment-scp-cost.yaml` - root SCP with a service allow list and
  denies for costly actions

### Import existing resources

Git sync creates no import change sets. Import a resource with the AWS CLI:

1. Add the resource to the template with `DeletionPolicy: Retain`. Commit, but
   don't push yet.
2. Create a change set of type `IMPORT` for the stack. Review it, then
   execute it.
3. Push. Git sync blocks the stack, because something else changed it.
4. Find the blocker and resolve it:

   ```bash
   aws codeconnections get-sync-blocker-summary \
     --resource-name <stack> \
     --sync-type CFN_STACK_SYNC \
     --region eu-central-1 \
     --no-cli-pager
   aws codeconnections update-sync-blocker \
     --id <blocker-id> \
     --resource-name <stack> \
     --sync-type CFN_STACK_SYNC \
     --resolved-reason "<reason>" \
     --region eu-central-1 \
     --no-cli-pager
   ```

5. Choose **Retry latest commit** in the Git sync tab of the stack.

### Account vending

git-repo-mgmt creates one AWS account per repository that sets
`enable_aws_account`. This repo provides the parts in the management account,
all in `cfn/iac.yaml` and `cfn/scp.yaml`:

* `AccountVendingRole` - only the git-repo-mgmt role in the automation account
  can assume it. It creates accounts with the tag `ManagedBy: git-repo-mgmt`
  and can move, tag, untag and close only accounts with that tag. It cannot
  remove the `ManagedBy` tag. It also manages the stack instances of the
  `ProjectRole` StackSet.
* `ProjectRole` StackSet - creates `<repo>-ProjectRole` with
  `AdministratorAccess` in a vended account. Only
  `GitHubOIDC-<repo>-ResourceAccess` in the automation account can assume it.
* `GitHubOIDCProvider` StackSet - deploys the GitHub OIDC provider to every
  account in the Projects OU.
* Projects OU SCP - only StackSets can change `*-ProjectRole`,
  `OrganizationAccountAccessRole`, the StackSet execution roles and the
  GitHub OIDC provider.
* Suspended OU SCP - denies all actions in parked accounts, except for the
  StackSet execution roles.

To revoke git-repo-mgmt's access to the organization, change or delete
`AccountVendingRole`.

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
