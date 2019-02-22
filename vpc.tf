resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true

    tags {
      Name = "web-app-vpc"
    }
}

resource "aws_subnet" "public-subnet" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "us-east-1a"

    tags {
      Name = "ALB Public Subnet"
    }
}

resource "aws_subnet" "private-subnet" {
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "us-east-1b"

    tags {
      Name = "Web Server Private Subnet"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.default.id}"

    tags {
      Name = "VPC IGW"
    }
}


# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
}

# Define the security group for public subnet
resource "aws_security_group" "sgweb" {
  name = "vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"


  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    #security_groups =["$aws_security_group.sg_alb_web.name"]
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.default.id}"

  tags {
    Name = "Web Server SG"
  }
}
resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "All ingress traffic from ALB"
  source_security_group_id = "${aws_security_group.sg_alb_web.id}"
  security_group_id = "${aws_security_group.sgweb.id}"
}

resource "aws_security_group_rule" "ingress-http" {
  type              = "ingress"
  from_port         = 0
  to_port           = 80
  protocol          = "tcp"
  description       = "All ingress traffic from ALB"
  source_security_group_id = "${aws_security_group.sg_alb_web.id}"
  security_group_id = "${aws_security_group.sgweb.id}"
}

resource "aws_security_group" "sg_alb_web" {
  name = "sg_alb_web"
  description = "Allow incoming HTTP connections"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.default.id}"

  tags {
    Name = "ALB Server SG"
  }
}


# Define the security group for private subnet
#resource "aws_security_group" "sgdb"{
#  name = "sg_test_web"
#  description = "Allow traffic from public subnet"

#  ingress {
#    from_port = 3306
#    to_port = 3306
#    protocol = "tcp"
#    cidr_blocks = ["${var.public_subnet_cidr}"]
#  }

#  ingress {
#    from_port = -1
#    to_port = -1
#    protocol = "icmp"
#    cidr_blocks = ["${var.public_subnet_cidr}"]
#  }

#  ingress {
#    from_port = 22
#    to_port = 22
#    protocol = "tcp"
#    cidr_blocks = ["${var.public_subnet_cidr}"]
#  }

#  vpc_id = "${aws_vpc.default.id}"

#  tags {
#    Name = "DB SG"
#  }
#}

resource "aws_alb" "alb_webserver" {
  subnets         = ["${aws_subnet.public-subnet.id}","${aws_subnet.private-subnet.id}"]
  security_groups = ["${aws_security_group.sg_alb_web.id}"]
  internal        = false
  tags {
    Name    = "alb webserver"
  }

}

resource "aws_alb_target_group" "targetg_alb_webserver" {

	vpc_id	= "${aws_vpc.default.id}"
  target_type = "instance"
	port	= "80"
	protocol	= "HTTP"
	health_check {
                path = "/"
                port = "80"
                protocol = "HTTP"
                healthy_threshold = 2
                unhealthy_threshold = 2
                interval = 5
                timeout = 4
                matcher = "200-308"
        }
}

resource "aws_alb_target_group_attachment" "alb_webserver-01" {
  target_group_arn = "${aws_alb_target_group.targetg_alb_webserver.arn}"
  target_id        = "${aws_instance.wb.id}"
  port             = 80
}
resource "aws_alb_target_group_attachment" "alb_webserver-02" {
  target_group_arn = "${aws_alb_target_group.targetg_alb_webserver.arn}"
  target_id        = "${aws_instance.wb1.id}"
  port             = 80
}

resource "aws_alb_listener" "alb_listener" {
    load_balancer_arn = "${aws_alb.alb_webserver.arn}"
    port = "80"
    protocol = "HTTP"

    default_action {
  		target_group_arn	=	"${aws_alb_target_group.targetg_alb_webserver.arn}"
  		type =	"forward"
	  }
}
