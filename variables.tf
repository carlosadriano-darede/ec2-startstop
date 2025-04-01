variable "aws_region" {
  type        = string
  description = "AWS region to use for resources."
  default     = "us-east-1"
}

variable "aws_azs" {
  type        = string
  description = "AWS Availability Zones"
  default     = "us-east-1a"
}


variable "stopstart_tags" {
  description = "Enable STOP/START for EC2 Instances with the following tag"
  default = {
    TagKEY   = "stopstart_me"
    TagVALUE = "yes"
  }
}

variable "stop_cron_schedule" {
  description = "Cron Expression when to STOP Servers in UTC Time zone"
  default     = "cron(32 08 ? * MON-FRI *)"
}

variable "start_cron_schedule" {
  description = "Cron Expression when to START Servers in UTC Time zone"
  default     = "cron(34 08 ? * MON-FRI *)"
}

variable "company" {
  type        = string
  description = "Company name for resource tagging"
  default     = "Darede Company"
}

variable "project" {
  type        = string
  description = "Project name for resource tagging"
  default     = "POC Darede"
}

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all resources."
  default     = "Darede"
}

variable "environment" {
  type        = string
  description = "Environment for deployment"
  default     = "POC-HML"
}

###By Carlos
variable "darede_tags" {
  description = "Enable STOP/START for EC2 Instances with the following tag"
  default = {
    TagKEY   = "env"
    TagVALUE = "hml"
  }
}

variable "instance_key" {
  default = "iac-dev"
}