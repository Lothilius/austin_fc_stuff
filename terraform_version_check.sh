#!/bin/bash

PROVIDERS_FILE="providers.tf"
TERRAFORM_FOLDER=".terraform"

if [ -f "$PROVIDERS_FILE" ]; then
  # Check if Terraform is initialized
  if [ -d "$TERRAFORM_FOLDER" ]; then
      # Use grep to find the required_version line and awk to extract just the version part
      VERSION=$(grep "required_version" "$PROVIDERS_FILE" | awk -F'"' '{print $2}')
      if [ -n "$VERSION" ]; then
          echo "$(tfenv version-name) -- $VERSION"
      fi
  else
      if [ -d "$PROVIDERS_FILE" ]; then
        echo "$(tfenv version-name) -- Run terraform init"
      fi
  fi
fi