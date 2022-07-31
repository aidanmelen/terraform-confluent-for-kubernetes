variable "name" {
  description = "The Kafka Topic name."
  type        = string
}

variable "namespace" {
  description = "The namespace of the Confluent Platform."
  type        = string
  default     = "confluent"
}

variable "values" {
  description = "The Kafka Topic override values."
  type        = any
  default     = {}
}

variable "create_timeout" {
  description = "The create timeout for each Conlfuent Platform component."
  type        = string
  default     = "5m"
}

variable "update_timeout" {
  description = "The update timeout for each Conlfuent Platform component."
  type        = string
  default     = "5m"
}

variable "delete_timeout" {
  description = "The delete timeout for each Conlfuent Platform component."
  type        = string
  default     = "5m"
}