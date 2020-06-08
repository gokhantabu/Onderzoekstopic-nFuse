resource "aws_glue_catalog_database" "myLogsTF" {
  name = "mylogstf"
}

resource "aws_glue_catalog_table" "raw_logs_nginxTF" {
  name          = "raw_logs_nginxtf"
  database_name = aws_glue_catalog_database.myLogsTF.name

  table_type = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://stage-demo-nfuse.453882275279/Logs/"
    input_format = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.serde2.RegexSerDe"

      parameters = {
        "input.regex" = "(\\d{4}\\/\\d{2}\\/\\d{2} \\d{2}:\\d{2}:\\d{2})\\s(\\[\\w*\\])\\s(\\d+\\#\\d+):\\s(.*)"
        "serialization.format" = 1
      }
    }

    columns {
      name = "timestamp"
      type = "string"
    }

    columns {
      name = "error_type"
      type = "string"
    }

    columns {
      name    = "pid_tid"
      type    = "string"
    }

    columns {
      name    = "message"
      type    = "string"
    }
  }
}