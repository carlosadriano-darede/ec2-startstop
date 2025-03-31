resource "aws_instance" "ec2_darede" {
  ami = "ami-0ae8f15ae66fe8cda" # Amazon Linux 2023 AMI, eu-west-3
  instance_type = "t2.micro"
  tags = {
    Name = "EC2_darede"
    aplicacao = "totvs"
    env = "hml"
  }
}