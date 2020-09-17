# This is the main file for creating a base environment with 1 vnet and 2 subnet (1 Private and 1 Public)
# Public subnet will have 1 ec2 with nginx installed
# Private vnet will have 1 ec2 instance with Db installed

/*
terraform {
   backend "local" {
       path = "${path.module}/testtfstate/terraform.tfstate"
    }
}*/

provider "aws" {
    profile = "aws-shan"
    region  = var.generic_details["region"]
}

resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_details["cidr"]
    tags = {
        Name = join("-",["vpc",var.generic_details["project_name"]]) 
        Environment = var.generic_details["environment"]
    }
}

resource "aws_internet_gateway" "ig" {
    vpc_id=aws_vpc.vpc.id
    tags = {
        Name = join("-",["ig",var.generic_details["project_name"]])
        Environment = var.generic_details["environment"]
    }
}



resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.vpc_details["pub_subnet"]
    availability_zone       = var.generic_details["availabilityzone"]
    map_public_ip_on_launch = true
    tags = {
          Name = join("-",["pub_subnet",var.generic_details["project_name"]])
          Environment = var.generic_details["environment"]
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.vpc_details["pvt_subnet"] 
    availability_zone       = var.generic_details["availabilityzone"]
    
    tags = {
          Name = join("-",["pvt_subnet",var.generic_details["project_name"]])
          Environment = var.generic_details["environment"]
    }
}


resource "aws_route_table" "pub_rt" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }
    tags = {
        Name = join("-",["rt_pub",var.generic_details["project_name"]]) 
        Environment = var.generic_details["environment"]
    }
}
resource "aws_route_table" "pvt_rt" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = join("-",["rt_pvt",var.generic_details["project_name"]]) 
        Environment = var.generic_details["environment"]
    }
}

resource "aws_route_table_association" "pub_rt_association" {
    subnet_id =  aws_subnet.public_subnet.id
    route_table_id= aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pvt_rt_association" {
    subnet_id =  aws_subnet.private_subnet.id
    route_table_id= aws_route_table.pvt_rt.id
}

resource "aws_security_group" "public_sg" {
    name        = "public_sg"
    description = "Used for access to the public instances"
    vpc_id      = aws_vpc.vpc.id

    #ssh
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = var.accessip
    }

    #HTTP

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = var.accessip
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = var.accessip
    }
}

# -- Storage 
resource "aws_s3_bucket" "storage" {
    bucket        = lower(join("-",["s3",var.generic_details["project_name"]]))
    acl           = "private"

    force_destroy =  true

    tags = {
        Name = join("-",["s3",var.generic_details["project_name"]]) 
        Environment = var.generic_details["environment"]
    }
}

# -- Create the instance 

resource "aws_key_pair" "auth" {
  key_name   = var.ec2_details["key_name"]
  public_key = file(var.ec2_details["public_key"])
  #private_key = file(var.ec2_details["private_key"])
}

resource "aws_instance" "linux_server" {
    instance_type = var.ec2_details["instance_type"]
    ami           = var.ec2_details["instance_ami"]
    key_name               = aws_key_pair.auth.key_name
    vpc_security_group_ids = [aws_security_group.public_sg.id]
    subnet_id              = aws_subnet.public_subnet.id
    

    tags = {
        Name = join("-",["ec2",var.generic_details["project_name"]]) 
        Environment = var.generic_details["environment"]
    } 



        connection {
        type           =   "ssh"
        user                    =   "ubuntu"
        host                    =   self.public_ip
        private_key             =   file("/Users/shanmugamkatna/.ssh/splunk.pem")
    }
        provisioner "file" {
            source = "/Users/shanmugamkatna/test.sh"
            destination = "/home/ubuntu/test.sh"
        }
        provisioner "remote-exec" {
        inline = [
         "chmod +x test.sh",
         "sh test.sh",
         "yum -y install ansible"
        ]
        on_failure = fail
    }
}


/*
resource "null_resource" "test" {
    connection {
        instance_type           =   "ssh"
        user                    =   "ubuntu"
        host                    =   aws_instance.linux_server.public_ip
        private_key             =   file(var.ec2_details["private_key"])
    }
   
    provisioner "remote-exec" {
        inline = [
            "sudo amazon-linux-extras enable nginx1.12",
            "sudo yum -y install nginx",
            "sudo systemctl start nginx"
        ]
    }
}
*/