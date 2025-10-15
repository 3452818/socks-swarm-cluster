
variable "yc_token" {
  description = "Yandex Cloud IAM token"
  type        = string
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "image_id" {
  description = "ID of the Ubuntu 20.04 LTS image"
  type        = string
  default     = "fd8gk6f87bbfmuctfl6t"
}
