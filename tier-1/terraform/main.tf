# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "inte/net_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "elb" {
  name        = "connector_elb"
  description = "Used for btp.${var.my_domain} load-balancer"
  vpc_id      = "${aws_vpc.default.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "connector"
  description = "Used for btp.${var.my_domain}"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "web" {
  name = "connector-elb"

  subnets         = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.web.id}"]

  listener {
    instance_port     = 8080
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_simpledb_domain" "connector" {
  name = "connector"
}

resource "aws_iam_policy" "connector-policy" {
  name = "connector-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "sdb:BatchDeleteAttributes",
      "sdb:BatchPutAttributes",
      "sdb:DeleteAttributes",
      "sdb:DeleteDomain",
      "sdb:DomainMetadata",
      "sdb:GetAttributes",
      "sdb:ListDomains",
      "sdb:PutAttributes",
      "sdb:Select"
    ],
    "Resource": "*"
  }
}
EOF
}

resource "aws_iam_role" "connector-instance" {
  name = "connector-instance"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Action": "sts:AssumeRole",
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    }
  }
}
EOF
}

resource "aws_iam_role_policy_attachment" "connector-policy-attachment" {
  role = "${aws_iam_role.connector-instance.name}"
  policy_arn = "${aws_iam_policy.connector-policy.arn}"
}

resource "aws_iam_instance_profile" "connector-instance-profile" {
  name = "connector-instance-profile"
  role = "${aws_iam_role.connector-instance.name}"
}

resource "aws_instance" "web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"

    # The connection will use the local SSH agent for authentication.
  }

  instance_type = "t2.small"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # Give permission to use SimpleDB
  iam_instance_profile = "${aws_iam_instance_profile.connector-instance-profile.name}"

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.default.id}"

  # TODO: Broken in 0.11.1, should be fixed in next release
  # provisioner "salt-masterless" {
  #   "local_state_tree" = "../salt/"
  # }

  # Upload the salt states
  provisioner "file" {
    source = "../salt"
    destination = "/home/ubuntu"
  }

  # We run a remote provisioner on the instance after creating it.
  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ubuntu/salt /srv/salt",
      "sudo apt-get -y update",
      "wget -O bootstrap-salt.sh https://bootstrap.saltstack.com",
      "sudo sh bootstrap-salt.sh",
      "sudo sh -c 'salt-call --local state.apply -l info'"
    ]
  }
}

resource "aws_route53_zone" "default" {
  name = "${var.my_domain}"
}

resource "aws_route53_record" "btp" {
  zone_id = "${aws_route53_zone.default.zone_id}"
  name = "btp.${var.my_domain}"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.web.dns_name}"]
}
