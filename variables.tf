variable "do_token" {
  description = "token for DO"
  type        = string
  default     = "Insert your values"
}

variable "aws_access_key" {
  description = "access_key for AWS"
  type        = string
  default     = "Insert your values"
}

variable "aws_secret_key" {
  description = "secret_key for AWS"
  type        = string
  default     = "Insert your values"
}

variable "my_key" {
  description = "my personal public_key key"
  type        = string
  default     = "Insert your keys values"
}

variable "e-mail" {
  description = "my E-mail"
  type        = string
  default     = "Insert your e-mail"
}

variable "dev" {
  description = "Informationen zu VPC"
  type        = map(any)
  default = {
    names_von_do_vpc = ["Insert your vps name", "Insert your vps name"]
  }
}

variable "zahlen" {
  description = "Zahlen VPC"
  type        = map(any)
  default = {
    num_von_vpc = "1"
  }
}
