#!/bin/bash

# SPDX-FileCopyrightText: 2025 Dominik Wombacher <dominik@wombacher.cc>
#
# SPDX-License-Identifier: MIT-0

set -euo pipefail

# Configuration
ROLE_NAME="AWSOrganizationsCloudFormationRole"
POLICY_NAME="AWSOrganizationsCloudFormationPolicy"
POLICY_FILE="iam-policy-cfn-aws-orgs.json"

log() {
    echo "INFO: $1"
}

error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

main() {
    log "AWS Organizations Management Setup"
    log "=================================="

    if ! command -v aws &> /dev/null; then
        error_exit "AWS CLI could not be found. Please install it and configure your credentials."
    fi

    if [ ! -f "$POLICY_FILE" ]; then
        error_exit "Policy file '$POLICY_FILE' not found in the current directory."
    fi

    # Get account ID and check credentials
    ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text --no-cli-pager)
    if [ -z "$ACCOUNT_ID" ]; then
        error_exit "Could not get AWS Account ID. Check your AWS credentials and permissions."
    fi
    log "Operating in AWS Account ID: $ACCOUNT_ID"

    # Check if role exists
    log "Checking if IAM role '$ROLE_NAME' exists..."
    if ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text --no-cli-pager 2>/dev/null); then
        log "Role '$ROLE_NAME' already exists: $ROLE_ARN"
    else
        log "Role '$ROLE_NAME' not found. Creating it..."
        ROLE_ARN=$(aws iam create-role \
            --role-name "$ROLE_NAME" \
            --assume-role-policy-document '{
                "Version": "2012-10-17",
                "Statement": [{
                    "Effect": "Allow",
                    "Principal": {"Service": "cloudformation.amazonaws.com"},
                    "Action": "sts:AssumeRole"
                }]
            }' \
            --query 'Role.Arn' --output text --no-cli-pager)

        log "Role created with ARN: $ROLE_ARN"
    fi

    # Attach or update the inline policy to ensure it's always in sync with the file.
    # This makes the script idempotent.
    log "Attaching/updating policy '$POLICY_NAME' to role '$ROLE_NAME'..."
    aws iam put-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-name "$POLICY_NAME" \
        --policy-document "file://$POLICY_FILE" \
        --no-cli-pager
    log "Policy attached/updated successfully."

    echo ""
    log "Setup completed successfully."
    echo "Role ARN: $ROLE_ARN"
    echo ""
}

main "$@"
