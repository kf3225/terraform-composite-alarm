variable "lambda_function" {
  type = object({
    source_dir    = string
    output_path   = string
    function_name = string
    role_name     = string
  })
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = var.lambda_function.source_dir
  output_path = var.lambda_function.output_path
}

resource "aws_iam_role" "this" {
  name = var.lambda_function.role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

output "arn" {
  value = aws_lambda_function.this.arn
}

output "name" {
  value = aws_lambda_function.this.function_name
}

resource "aws_lambda_function" "this" {
  filename         = data.archive_file.this.output_path
  function_name    = var.lambda_function.function_name
  role             = aws_iam_role.this.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.this.output_base64sha256
  runtime          = "python3.8"
}
