#version=1.0.0-SNAPSHOT

locals {
  VERSION = "1.2.9"
}

packer {
  required_plugins {
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "packer-svn" {
  ami_description      = "Redhat Linux Image with SVN server"
  ami_name             = "Packer-SVN/${local.VERSION}"
  instance_type        = "t2.xlarge"
  region               = "eu-central-1"
  source_ami           = "ami-0ece51165476e7656"
  communicator         = "ssh"
  ssh_username         = "ec2-user"
  iam_instance_profile = "prov-EC2PackerInstanceProfile"

  subnet_filter {
    filters = {
      "tag:Name" : "subnet-App-*"
    }
    most_free = true
  }

  associate_public_ip_address = false

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 30 # Adjust size as needed
    volume_type           = "gp3"
    encrypted             = true # Enable encryption
    ##Packer Build KMS | AWS-PROD SST
    kms_key_id = "7ad1cb64-46d3-4693-88c4-0f878a2108dc"
    delete_on_termination = true # Delete volume on instance termination
  }

  tags = {
    "Name"        = "Packer-SVN"
    "OS_version"  = "Redhat Enterprise Linux 8"
    "Created-by"  = "Packer-Builder"
    "PV-Version"  = "${local.VERSION}"
  }

}

build {
  name    = "packer-svn"
  sources = ["source.amazon-ebs.packer-svn"]

provisioner "shell" {
  inline = [
    "echo Installing AWS CLI",
    "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
    "unzip awscliv2.zip",
    "sudo ./aws/install",
    "aws --version"  // Verify the installation
  ]
}

  provisioner "ansible" {
    user ="ec2-user"
    playbook_file = "./ansible/playbook.yml"
    extra_arguments = ["-vvv"]
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }


}