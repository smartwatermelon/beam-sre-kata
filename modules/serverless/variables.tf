# ./modules/serverless/variables.tf

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
}