## Initialize Terraform
```
terraform init
```

## Check the Terraform plan
```
terraform plan -var-file=dev.tfvars
```

## Apply the template
```
terraform apply -auto-approve -var-file=dev.tfvars
```

## Destroy all the created resources
```
terraform destroy -auto-approve -var-file=dev.tfvars
```

## Terraform configuration file - ie, dev.tfvars

example code

```
root_block_device = [{
  volume_size = 20
  volume_type = "gp2"
}]

root_block_device_size = 20

ami            = "Your preferred AMI"
instance_type  = "Your preferred instance type"
instance_count = 1
public_key     = "Enter your SSH public key here"
```
