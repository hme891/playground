# Bootstrap Deployment Guide

## Deployment Process and Verification

### 1. Infrastructure Deployment

The terraform deployment process creates all necessary AWS resources:

![Deployment Complete](bootstrap/deployment.png)
_Successful completion of resource deployment_

### 2. Resource Verification

![VPC Configuration 1](bootstrap/vpc.png)
_VPC setup and configuration details_

![Subnet Configuration 1](bootstrap/subnet.png)
_Subnet setup and configuration details_

## Cleanup

To destroy the infrastructure when no longer needed:

```shell
terraform workspace select bootstrap
terraform destroy -var-file=terraform.tfvars  -var-file="bootstrap.tfvars"
```
