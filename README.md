# Building EKS cluster using Terraform

This repository provides how to build eks cluster using terraform

## Install AWSCLI

```
curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"  
unzip awscliv2.zip  
sudo ./aws/install 
```

## Install Terraform

```
sudo snap install terraform --classic
```

## Run Terraform code

```
terraform init
terraform apply
```
