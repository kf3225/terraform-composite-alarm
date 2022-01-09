variable "sns_topic" {
  type = object({
    name = string
  })
}

variable "sns_topic_subscription" {
  type = object({
    protocol = string
    endpoint = string
  })
}

output "arn" {
  value = aws_sns_topic.this.arn
}

resource "aws_sns_topic" "this" {
  name = var.sns_topic.name
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = var.sns_topic_subscription.protocol
  endpoint  = var.sns_topic_subscription.endpoint
}
