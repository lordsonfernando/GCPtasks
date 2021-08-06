variable "source_project" {
  description = "source pid"

}
variable "bucket_name" {
  description = "bucket to store unprocessed csv"

}
variable "source_dataset" {
  description = "dataset to process with dlp"

}
variable "source_table" {
  description = "table to process with dlp"

}


variable "destination_project" {
  description = "destination pid"

}

variable "destination_dataset" {
  description = "dataset to store processed dlp"

}
variable "destination_table" {
  description = "table to store processed dlp"

}
variable "service_account" {
  description = "service account"
}
variable "region" {
  description = "dataset to store processed dlp"

}

variable "zone" {
  description = "dataset to store processed dlp"

}
variable "dataflow_network" {
  description = "dataset to store processed dlp"

}
variable "dataflow_subnet" {
  description = "dataset to store processed dlp"

}
variable "temp_bucket" {
  description = "temporary bucket for processed dlp"

}

