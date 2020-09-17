generic_details = {
    region="ca-central-1"
    project_name = "Finacle"
    environment = "Development"
    availabilityzone="ca-central-1a"
}

vpc_details = {
        cidr="10.0.0.0/16"
        pub_subnet="10.0.1.0/24"
        pvt_subnet="10.0.2.0/24"
}

ec2_details = {
    key_name        = "web-server"
    public_key      = "/Users/shanmugamkatna/.ssh/id_rsa.pub"
    instance_type   = "t2.micro"
    instance_ami             = "ami-0e2df0719252d4491" 
}