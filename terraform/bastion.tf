resource "aws_key_pair" "deployer" {
  key_name = "ls-${var.cluster_name}-bastion-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZCsz91Hxu6ja4suPmOoqr3LRXcoCE6OPpgld5/4k/rzxa27bAwtglpaIQWC7UVlbuCVUhT8ArHKLlJ7S/F6A0nFNqxb5wHpAE5WbyF3zJpb2iUorx9tvSYXSSnpgAJR+td54WkRnt+Avux+Xhbxh2i5bvH5fGBxWfNIzi9oZxNUJYP04QmgdaybBjVbmSyTe6RQK+PbI6htAuqFJiNI7auMnWNCmWO4Zi6C0ptmyMNxVoQ5CzzGMAfAak5knz8AravbDHpa+8v4t5X7JYAetav6ZjOfaatrjuMpdUjDlV+3Nw5FT4u48bNP4KRLCrwkHFWJwLjhaO+R/owXvZi45F"
}

resource "aws_security_group" "bastion_access" {
  name_prefix = "${var.cluster_name}-bastion-access"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = merge(var.default_tags, {
    Name = "${var.cluster_name}-bastion"
  })
}


data "template_file" "bastion-provision" {
  template = file("${path.module}/templates/scripts/bootstrap-bastion.sh")
}

resource "aws_instance" "bastion" {
  ami = "ami-0cb1c8cab7f5249b6" # NOTE: IDs of AMI are different per region.
  instance_type = "t2.nano"
  availability_zone = data.aws_availability_zones.available.names[0]

  vpc_security_group_ids = [
    aws_security_group.eks_internal.id,
    aws_security_group.bastion_access.id
  ]

  key_name = aws_key_pair.deployer.key_name

  subnet_id = module.vpc.public_subnets[0]

  associate_public_ip_address = true

  tags = merge(var.default_tags, {
    Name = "${var.cluster_name}-bastion"
  })

  user_data = data.template_file.bastion-provision.rendered
}