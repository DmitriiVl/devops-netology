###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "public_key" {
  type    = string
  default = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9mi/8PO7m2/yrKy7ZnFr15bvdUrC6DUmqn/5DVKiHAO7hy9e9b+ktQ5WaejyCyrPr4pn474suPPLL2s6ZY71041pwKD2kQ1QeYNL0woHqOFCjlxeXpDAGVwUkwFekyUwCwmM1WWpZ9IqhPB50kN2FHnbzMONFti6nGJ/hl7sS9MH4+lKjf/eKQFBn/0u7Dm07RyFRCxc2ui8H1CSXJk84fWcmEftuJlQ9BrGuG2BWXtlCBgRbzb0Fg/AP+3LHi5N9CrxsN1YWdxPj80k9omrlKA5pEO5iuEWIJDjuNRTZnniLV6NgaDAsJuekLy9CzburqpAIycI6EK86KDUHr1sqRMnqjNVwdjbZ8z8W8PYlwpi3skmY9mNyGyGJcdLKgeno5S9NMmbcNNWGixdf6AdEvNL/pnLf/JHnEiO0S2WvCf8zMC6PKC65cneMtNTHfBMAxryFzr1HGJ7h4bQoL/X5uor1gbh5UwBYntSaAgKwl7aRi8dbeJaNg4eN2PC0E5U= dmivlad@Ubuntu20"
}

variable "ssh_key" {
  type = string
  default = "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"
}