variable "cloudwatch_metric_alarm" {
  type = object({
    alarm_name          = string
    comparison_operator = string
    evaluation_periods  = string
    threshold           = string
    alarm_description   = string
    alarm_actions       = list(string)
    ok_actions          = list(string)
    metric_query        = any
  })
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.this.alarm_name
}

resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = var.cloudwatch_metric_alarm.alarm_name
  comparison_operator = var.cloudwatch_metric_alarm.comparison_operator
  evaluation_periods  = var.cloudwatch_metric_alarm.evaluation_periods
  threshold           = var.cloudwatch_metric_alarm.threshold
  alarm_description   = var.cloudwatch_metric_alarm.alarm_description
  alarm_actions       = var.cloudwatch_metric_alarm.alarm_actions
  ok_actions          = var.cloudwatch_metric_alarm.ok_actions

  dynamic "metric_query" {
    for_each = lookup(var.cloudwatch_metric_alarm, "metric_query", [])
    content {
      id          = lookup(metric_query.value, "id")
      expression  = lookup(metric_query.value, "expression", null)
      label       = lookup(metric_query.value, "label", null)
      return_data = lookup(metric_query.value, "return_data", null)

      dynamic "metric" {
        for_each = lookup(metric_query.value, "metric", [])
        content {
          metric_name = lookup(metric.value, "metric_name")
          namespace   = lookup(metric.value, "namespace")
          period      = lookup(metric.value, "period")
          stat        = lookup(metric.value, "stat")
          unit        = lookup(metric.value, "unit", null)
          dimensions  = lookup(metric.value, "dimensions", null)
        }
      }
    }
  }
}
