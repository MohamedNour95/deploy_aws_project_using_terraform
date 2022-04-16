# deploy_aws_project_using_terraform
. Making dynamic VPC on AWS using Terraform to deploy Nginx Docker container

# Set-up
1. master branch files:
. main.tf: contains all the terraform code
. terraform.tfvars: contains all variables values used in main.tf file
. entry-script.sh: contains bash script to install docker and run Nginx container
2. feature/module branch files:
. modules: contains subnet and webserver modules each contains main.tf,outputs.tf,variables.tf
. main.tf: contains the main module
. outputs.tf: contains the main outputs
. varibles.tf: contains the main variables

# Run the code
. initialize 
```
terraform init
```
. preview terraform actions
```
terraform plan
```
. apply configuration
```
terraform apply
```