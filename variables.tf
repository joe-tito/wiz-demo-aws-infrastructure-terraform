variable "key_pair_name" {
  type        = string
  description = "Key pair used to ssh into mongo ec2 instance"
}

variable "mongo_user" {
  type        = string
  description = "Username used to create mongo database"
}

variable "mongo_password" {
  type        = string
  description = "Password user to create mongo database"
}
