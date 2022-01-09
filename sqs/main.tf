variable "sqs_queue" {
  type = object({
    name = string
  })
}

output "arn" {
  value = aws_sqs_queue.this.arn
}

resource "aws_sqs_queue" "this" {
  name = var.sqs_queue.name
}
