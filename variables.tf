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

variable "container_name" {
  type        = string
  description = "Name used for the web app container"
  default     = "web-app"
}

variable "container_port" {
  type        = number
  description = "Port to expose for the web app container"
  default     = 3000
}

variable "container_tag" {
  type        = string
  description = "Tag version of container image to use"
  default     = "386e4bab"
}
