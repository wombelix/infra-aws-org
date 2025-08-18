#!/bin/bash

# SPDX-FileCopyrightText: 2025 Dominik Wombacher <dominik@wombacher.cc>
#
# SPDX-License-Identifier: MIT-0

set -euo pipefail

# Configuration
ROLE_NAME="CustomerServiceRoleForCloudformationInfraAWSOrg"
POLICY_NAME="CustomerPolicyForCloudformationInfraAWSOrg"
POLICY_FILE="iam-policy-cfn-aws-orgs.json"

log() {
    echo "INFO: $1"
}

error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

# Function to compare JSON documents
# Returns 0 if JSON documents are equivalent, 1 otherwise
compare_json() {
    local json1="$1"
    local json2="$2"

    # Normalize JSON using jq for comparison (removes whitespace differences)
    if command -v jq &> /dev/null; then
        local normalized1 normalized2
        normalized1=$(echo "$json1" | jq -S . 2>/dev/null) || return 1
        normalized2=$(echo "$json2" | jq -S . 2>/dev/null) || return 1
        [ "$normalized1" = "$normalized2" ]
    else
        # Fallback comparison without jq (less reliable)
        [ "$json1" = "$json2" ]
    fi
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

    # Define the expected assume role policy document
    ASSUME_ROLE_POLICY='{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "cloudformation.amazonaws.com"},
            "Action": "sts:AssumeRole"
        }]
    }'

    # Check if role exists
    log "Checking if IAM role '$ROLE_NAME' exists..."
    if aws iam get-role --role-name "$ROLE_NAME" --no-cli-pager &> /dev/null; then
        log "Role '$ROLE_NAME' already exists. Checking if updates are needed..."

        # Get current assume role policy document
        CURRENT_ASSUME_ROLE_POLICY=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.AssumeRolePolicyDocument' --output json --no-cli-pager)

        # Compare assume role policies
        if compare_json "$ASSUME_ROLE_POLICY" "$CURRENT_ASSUME_ROLE_POLICY"; then
            log "Assume role policy is up-to-date."
        else
            log "Updating assume role policy..."
            aws iam update-assume-role-policy \
                --role-name "$ROLE_NAME" \
                --policy-document "$ASSUME_ROLE_POLICY" \
                --no-cli-pager
            log "Assume role policy updated successfully."
        fi
    else
        log "Role '$ROLE_NAME' not found. Creating it..."
        aws iam create-role \
            --role-name "$ROLE_NAME" \
            --assume-role-policy-document "$ASSUME_ROLE_POLICY" \
            --no-cli-pager > /dev/null

        log "Role created successfully."
    fi

    # Get the current role ARN
    ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text --no-cli-pager)

    # Check if the inline policy exists and compare it with our local version
    log "Checking if policy '$POLICY_NAME' exists and is up-to-date..."

    if aws iam get-role-policy --role-name "$ROLE_NAME" --policy-name "$POLICY_NAME" --no-cli-pager &> /dev/null; then
        # Policy exists, get current policy document
        CURRENT_POLICY=$(aws iam get-role-policy --role-name "$ROLE_NAME" --policy-name "$POLICY_NAME" --query 'PolicyDocument' --output json --no-cli-pager)

        # Read local policy file
        LOCAL_POLICY=$(cat "$POLICY_FILE")

        # Compare policies
        if compare_json "$LOCAL_POLICY" "$CURRENT_POLICY"; then
            log "Policy '$POLICY_NAME' is up-to-date."
        else
            log "Policy '$POLICY_NAME' has changed. Updating..."
            aws iam put-role-policy \
                --role-name "$ROLE_NAME" \
                --policy-name "$POLICY_NAME" \
                --policy-document "file://$POLICY_FILE" \
                --no-cli-pager
            log "Policy updated successfully."
        fi
    else
        # Policy doesn't exist, create it
        log "Policy '$POLICY_NAME' not found. Creating it..."
        aws iam put-role-policy \
            --role-name "$ROLE_NAME" \
            --policy-name "$POLICY_NAME" \
            --policy-document "file://$POLICY_FILE" \
            --no-cli-pager
        log "Policy created successfully."
    fi

    echo ""
    log "Setup completed successfully."
    echo "Role ARN: $ROLE_ARN"
    echo ""
}

main "$@"
