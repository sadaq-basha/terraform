#!/bin/bash
TF_CLI_ARGS_plan="-var-file=vars/$(terraform workspace show).tfvars" \
TF_CLI_ARGS_apply="-var-file=vars/$(terraform workspace show).tfvars" \
terraform $@