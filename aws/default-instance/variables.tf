variable "workspace" {
  type    = string
  default = "simple"
}

variable "instance_name" {
  type    = string
  default = "instance"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "key_name" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "instance_tags" {
  type    = map(string)
  default = {}
}

variable "security_group_name" {
  type    = string
  default = "security_group"
}

variable "security_group_description" {
  type    = string
  default = "Security group for instance"
}

variable "security_group_tags" {
  type    = map(string)
  default = {}
}
