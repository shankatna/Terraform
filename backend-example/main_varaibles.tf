variable "generic_details" {
    type = map   
}

variable "vpc_details" {
    type = map
}

variable "accessip" {
    type = list(string)
    default = ["0.0.0.0/0"]
}

variable "ec2_details" {
    type = map
}