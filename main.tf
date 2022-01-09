variable "env_name" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "test-project"
}

module "lambda" {
  source = "./lambda"
  lambda_function = {
    source_dir    = "./lambda/function"
    output_path   = "archive.zip"
    function_name = "${var.project_name}-${var.env_name}-function"
    role_name     = "${var.project_name}-${var.env_name}-role"
  }
}

module "sqs" {
  source   = "./sqs"
  for_each = toset(["error-action"])
  sqs_queue = {
    name = "${var.project_name}-${var.env_name}-sqs-${each.value}"
  }
}

module "sns" {
  source   = "./sns"
  for_each = toset(["error-action"])
  sns_topic = {
    name = "${var.project_name}-${var.env_name}-sns-topic-${each.value}"
  }
  sns_topic_subscription = {
    protocol = "sqs"
    endpoint = module.sqs[each.value].arn
  }
}

module "cloudwatch_metric_alarm_error_count" {
  source = "./cloudwatch/metric_alarm"
  cloudwatch_metric_alarm = {
    alarm_name          = "${var.project_name}-${var.env_name}-cloudwatch-alarm-error-count"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = "1"
    threshold           = "10"
    alarm_description   = "Lambda function's error count check."
    alarm_actions       = []
    ok_actions          = []
    metric_query = [
      {
        id          = "e1"
        label       = "Error count"
        return_data = "true"
        metric = [
          {
            metric_name = "Errors"
            namespace   = "AWS/Lambda"
            period      = "300"
            stat        = "Sum"
            dimensions = {
              "FunctionName" = module.lambda.name
            }
          }
        ]
      }
    ]
  }
}

module "cloudwatch_metric_alarm_error_rate" {
  source = "./cloudwatch/metric_alarm"
  cloudwatch_metric_alarm = {
    alarm_name          = "${var.project_name}-${var.env_name}-cloudwatch-alarm-error-rate"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = "1"
    threshold           = "50"
    alarm_description   = "Lambda function's error rate check."
    alarm_actions       = []
    ok_actions          = []
    metric_query = [
      {
        id          = "e1"
        label       = "Error rate"
        expression  = "m1/m2*100"
        return_data = "true"
      },
      {
        id    = "m1"
        label = "Error count"
        metric = [{
          metric_name = "Errors"
          namespace   = "AWS/Lambda"
          period      = "300"
          stat        = "Sum"
          dimensions = {
            "FunctionName" = module.lambda.name
          }
        }]
      },
      {
        id    = "m2"
        label = "Invocations"
        metric = [{
          metric_name = "Invocations"
          namespace   = "AWS/Lambda"
          period      = "300"
          stat        = "Sum"
          dimensions = {
            "FunctionName" = module.lambda.name
          }
        }]
      }
    ]
  }
}

locals {
  alarm_rule = <<EOF
ALARM(${module.cloudwatch_metric_alarm_error_count.alarm_name}) AND
ALARM(${module.cloudwatch_metric_alarm_error_rate.alarm_name})
EOF
}

module "cloudwatch_composite_alarm_error_count_and_rate" {
  source = "./cloudwatch/composite_alarm"
  cloudwatch_composite_alarm = {
    alarm_description = "Lambda function's error count and rate check."
    alarm_name        = "${var.project_name}-${var.env_name}-cloudwatch-alarm-error-count-and-rate"
    alarm_actions     = [module.sns["error-action"].arn]
    ok_actions        = []
    # 公式ドキュメントに倣ってヒアドキュメントを利用した方法で実装すると改行の問題でエラーになるので注意
    # alarm_rule        = local.alarm_rule
    alarm_rule = trimspace(replace(local.alarm_rule, "/\n+/", " "))
  }
}
