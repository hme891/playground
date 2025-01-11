# Linux Deployment Guide

## Build Process

The process starts with building the custom AMI:

![Build Process](linux/build1.png)
_Initial build phase of the Linux AMI_

![Build Complete](linux/build2.png)
_Successful completion of AMI creation_

## Deployment Process and Verification

### 1. Infrastructure Deployment

The terraform deployment process creates all necessary AWS resources:

![Deployment Process](linux/deployment-run.png)
_Terraform applying the infrastructure changes_

![Deployment Complete](linux/deployment-done.png)
_Successful completion of resource deployment_

### 2. Resource Verification

#### EC2 Instance

![EC2 Dashboard](linux/ec2.png)
_Verification of running Linux EC2 instance with correct configurations_

#### Application Load Balancer

![ALB Configuration 1](linux/alb1.png)
_ALB setup and configuration details_

![ALB Configuration 2](linux/alb2.png)
_ALB listener and target group verification_

### 3. Application Verification

#### SSL Certificate

![SSL Certificate](linux/web-cert.png)
_Verification of SSL certificate installation and HTTPS functionality_

#### Web Application

![Web Application](linux/web.png)
_Successful deployment of Nginx web application_

## Cleanup

To destroy the infrastructure when no longer needed:

```shell
terraform workspace select linux
terraform destroy -var-file=linux.tfvars
```
