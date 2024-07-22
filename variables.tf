# ./variables.tf
variable "redis_static_ip" {
  description = "Static IP address for the Redis container"
  type        = string
  default     = "10.0.5.240" # This should be within the private subnet CIDR range
}
