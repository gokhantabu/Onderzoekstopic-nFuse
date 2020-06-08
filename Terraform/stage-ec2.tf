data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "Allow_SSH_HTTP"
  description = "Allow HTTP and SSH trafic"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

data "template_file" "user_data" {
  template = file("resources/web/user_data.sh.tpl")
}

resource "aws_instance" "webserver" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_ssh_http.name]
  user_data = data.template_file.user_data.rendered
  iam_instance_profile = aws_iam_instance_profile.instance_profile_EC2.id
  key_name = "EC2-key"
  tags = {
    Name = "WebServer"
  }
}

resource "aws_iam_instance_profile" "instance_profile_EC2" {
  name = "test_profile"
  role = aws_iam_role.allowEC2ToS3.name
}
