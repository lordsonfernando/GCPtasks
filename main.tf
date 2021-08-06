# Bucket to store the csv file extracted from bigquery tables(raw user data,yet to be processed by dlp dataflow job)
resource "google_storage_bucket" "source_bucket" {
  name                        = var.bucket_name
  project                     = var.source_project
  location                    = var.region
  storage_class               = "STANDARD"
  force_destroy               = true
  uniform_bucket_level_access = false


}

#convert bigquery table to csv and stores in a bucket
resource "google_bigquery_job" "jobs" {
  job_id     = "job_extract_dest_source_two"

  extract {
    destination_uris = ["${google_storage_bucket.source_bucket.url}/extract.csv"]
    source_table {
      project_id = var.source_project
      dataset_id = var.source_dataset
      table_id   = var.source_table
    }

    destination_format = "CSV"
  }
}

# Template to deidentify personal information
resource "google_data_loss_prevention_deidentify_template" "basic" {
     parent = "projects/${var.destination_project}"
     
    description  = "Description"
    display_name = "DeidentifyTemp"

    deidentify_config {
        info_type_transformations {
            transformations {
                info_types {
                    name = "PHONE_NUMBER"
                }

                primitive_transformation {
                    replace_config {
                        new_value {
                            integer_value = 5
                        }
                    }
                }
            }

            transformations {
                info_types {
                    name = "EMAIL_ADDRESS"
                }

                primitive_transformation {
                    character_mask_config {
                        masking_character = "X"
                        number_to_mask = 10
                        reverse_order = false
                        characters_to_ignore {
                            common_characters_to_ignore = "PUNCTUATION"
                        }
                    }
                }
            }

          
           transformations {
                info_types {
                    name = "DATE_OF_BIRTH"
                }

                primitive_transformation {
                    replace_config {
                        new_value {
                            date_value {
                                year  = 2020
                                month = 1
                                day   = 1
                            }
                        }
                    }
                }
            }
            
        }
    }
}

#Dataflow job: converts raw csv data to deidentified data and stores it in a bigquery table
resource "google_dataflow_job" "temp_job" {
     depends_on = [
    google_bigquery_job.jobs,
  ]
  name                  = "dlp_example_test"
  region                = var.region
  zone                  = var.zone
  network               = var.dataflow_network
  subnetwork            = "regions/${var.region}/subnetworks/${var.dataflow_subnet}"
  template_gcs_path     = "gs://dataflow-templates/latest/Stream_DLP_GCS_Text_to_BigQuery"
  temp_gcs_location     = "gs://${var.temp_bucket}"
  service_account_email = var.service_account #service account with destination permissions 
  enable_streaming_engine = true

  parameters = {
    inputFilePattern       = "gs://${google_storage_bucket.source_bucket.name}/extract.csv"
    datasetName            = var.destination_dataset
    batchSize              = 1000
    dlpProjectId           = var.destination_project
    deidentifyTemplateName = google_data_loss_prevention_deidentify_template.basic.id 
  }
   on_delete             = "cancel"
 
}