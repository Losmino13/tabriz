resource "aws_appautoscaling_target" "service" {
  count = var.enable_autoscaling ? 1 : 0

  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = "service/${module.cluster.name}/${module.service.name}"

  min_capacity = var.autoscaling_min_capacity
  max_capacity = var.autoscaling_max_capacity

  tags = local.tags
}

resource "aws_appautoscaling_policy" "scale_out" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${local.service_name}-scale-out"
  policy_type        = "StepScaling"
  service_namespace  = aws_appautoscaling_target.service[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.service[0].scalable_dimension
  resource_id        = aws_appautoscaling_target.service[0].resource_id

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.autoscaling_scale_out_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "scale_in" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${local.service_name}-scale-in"
  policy_type        = "StepScaling"
  service_namespace  = aws_appautoscaling_target.service[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.service[0].scalable_dimension
  resource_id        = aws_appautoscaling_target.service[0].resource_id

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.autoscaling_scale_in_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.enable_autoscaling ? 1 : 0

  alarm_name          = "${local.service_name}-cpu-high"
  alarm_description   = "Scale out ${local.service_name}: CPU >= ${var.autoscaling_cpu_high_threshold}%"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 3
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.autoscaling_cpu_high_threshold

  dimensions = {
    ClusterName = module.cluster.name
    ServiceName = module.service.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_out[0].arn]

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count = var.enable_autoscaling ? 1 : 0

  alarm_name          = "${local.service_name}-cpu-low"
  alarm_description   = "Scale in ${local.service_name}: CPU <= ${var.autoscaling_cpu_low_threshold}%"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 15
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = var.autoscaling_cpu_low_threshold

  dimensions = {
    ClusterName = module.cluster.name
    ServiceName = module.service.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_in[0].arn]

  tags = local.tags
}

# resource "aws_cloudwatch_metric_alarm" "memory_high" {
#   count = var.enable_autoscaling ? 1 : 0
#
#   alarm_name          = "${local.service_name}-memory-high"
#   alarm_description   = "Scale out ${local.service_name}: memory >= ${var.autoscaling_memory_high_threshold}%"
#   namespace           = "AWS/ECS"
#   metric_name         = "MemoryUtilization"
#   statistic           = "Average"
#   period              = 60
#   evaluation_periods  = 3
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   threshold           = var.autoscaling_memory_high_threshold
#
#   dimensions = {
#     ClusterName = module.cluster.name
#     ServiceName = module.service.name
#   }
#
#   alarm_actions = [aws_appautoscaling_policy.scale_out[0].arn]
#
#   tags = local.tags
# }
#
# resource "aws_cloudwatch_metric_alarm" "memory_low" {
#   count = var.enable_autoscaling ? 1 : 0
#
#   alarm_name          = "${local.service_name}-memory-low"
#   alarm_description   = "Scale in ${local.service_name}: memory <= ${var.autoscaling_memory_low_threshold}%"
#   namespace           = "AWS/ECS"
#   metric_name         = "MemoryUtilization"
#   statistic           = "Average"
#   period              = 60
#   evaluation_periods  = 15
#   comparison_operator = "LessThanOrEqualToThreshold"
#   threshold           = var.autoscaling_memory_low_threshold
#
#   dimensions = {
#     ClusterName = module.cluster.name
#     ServiceName = module.service.name
#   }
#
#   alarm_actions = [aws_appautoscaling_policy.scale_in[0].arn]
#
#   tags = local.tags
# }
