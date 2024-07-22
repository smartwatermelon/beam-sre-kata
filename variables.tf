# ./variables.tf
variable "redis_static_ip" {
  description = "Static IP address for the Redis container"
  type        = string
  default     = "10.0.7.144" # this is terrible
}
