resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "RegistrationLogsTF"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "logsId"

  attribute {
    name = "logsId"
    type = "S"
  }

  attribute {
    name = "fileName"
    type = "S"
  }

  attribute {
    name = "registrationDate"
    type = "S"
  }

  global_secondary_index {
    name               = "fileName-index"
    hash_key           = "fileName"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "INCLUDE"
    non_key_attributes = [
      "registrationDate",
      "fileName",
      "registrationTime"
    ]
  }

  global_secondary_index {
    name               = "registrationDate-index"
    hash_key           = "registrationDate"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "ALL"
  }
}