#!/bin/bash

terraform -chdir=infrastructure/ plan
terraform -chdir=infrastructure/ apply
