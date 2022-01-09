variable "cloudwatch_composite_alarm" {
  type = object({
    alarm_description = string
    alarm_name        = string
    alarm_actions     = list(string)
    ok_actions        = list(string)
    alarm_rule        = string
  })
}

resource "aws_cloudwatch_composite_alarm" "this" {
  alarm_name        = lookup(var.cloudwatch_composite_alarm, "alarm_name")
  alarm_rule        = lookup(var.cloudwatch_composite_alarm, "alarm_rule")
  alarm_description = lookup(var.cloudwatch_composite_alarm, "alarm_description", null)
  alarm_actions     = lookup(var.cloudwatch_composite_alarm, "alarm_actions", [])
  ok_actions        = lookup(var.cloudwatch_composite_alarm, "ok_actions", [])
}
