output "op_vpc" {
    value=aws_vpc.vpc.id
}
output "op_subnet" {
    value=aws_subnet.public_subnet.id
}
output "op_internet_gateway" {
    value=aws_internet_gateway.ig.id
}
output "ec2_instance_ip"{
    value=aws_instance.linux_server.public_ip
}
    