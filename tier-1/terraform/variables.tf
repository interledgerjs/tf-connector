variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.

Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "my_domain" {
  description = "Domain name to host the connector on."
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

# Ubuntu 16.04 LTS (x64)
variable "aws_amis" {
  default = {
    ap-northeast-1 = "ami-42ca4724"
    ap-south-1 = "ami-84dc94eb"
    ap-southeast-1 = "ami-29aece55"
    ca-central-1 = "ami-b0c67cd4"
    eu-central-1 = "ami-13b8337c"
    eu-west-1 = "ami-63b0341a"
    sa-east-1 = "ami-8181c7ed"
    us-east-1 = "ami-3dec9947"
    us-west-1 = "ami-1a17137a"
    cn-north-1 = "ami-fc25f791"
    cn-northwest-1 = "ami-e5b0a587"
    us-gov-west-1 = "ami-6261ee03"
    ap-northeast-2 = "ami-5027813e"
    ap-southeast-2 = "ami-9b8076f9"
    eu-west-2 = "ami-22415846"
    us-east-2 = "ami-597d553c"
    us-west-2 = "ami-a2e544da"
    eu-west-3 = "ami-794bfc04"
  }
}
