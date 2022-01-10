provider "aws" {
  region  = var.region
}
resource "aws_security_group" "JenkinsSG" {
  name = "Jenkins SG"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "JenkinsEC2" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.JenkinsSG.id]
  key_name               = "aws_key"
  
 

  tags = {
    Name = "terraform-jenkins-master"
  }
  user_data = file("userdata.sh")


  connection {
  type        = "ssh"
  host        = self.public_ip
  user        = "ubuntu"
  private_key = file("/C/Users/Jaint/aws/aws_key")
  timeout     = "4m"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]

}
resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7Clkv5j2fZlHsJN+Glym8OE9DfoVXH+Hdum2Yn2A7OKOFJnLEGYnvpj1LlornmDiPO9nR97WM9YrIgR/mMkn6aguijb2gwMS43fHaHMRUFcjXDsr5NA7uvt+B1e7KEdKap2XcQ/ZhA/5v6zzOdKEkyWgtb+HjkcotiqFEnW9bNgUXBDEKNzxhAd3NQNRwOFCFvAmnkYUsZfoI04wbWadhelbCWlZmpF8VDxURQjFX8HhRLjLZAGoGBQW2ebeec+QzdYVTZXpQSLMukXXvo2iTm1GjWcSqyX0DTgHfZwNxtxbXZe7nf7W7ZxLpajfGDgDUi90zc+JBJ3TSl1C/RzuV JainT@MELAJAINT1"
}

output "jenkins_endpoint" {
  value = formatlist("http://%s:%s/", aws_instance.JenkinsEC2.*.public_ip, "8080")
}