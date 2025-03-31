################################################################################
# Lambda IAM permissions
################################################################################
resource "aws_iam_role" "lambda" {
  name               = "lambda-stop-start-ec2-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda" {
  name   = "lambda-stop-start-ec2-iam-policy"
  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Sid"   : "LoggingPermissions",
              "Effect": "Allow",
              "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
              ],
              "Resource": [
                  "arn:aws:logs:*:*:*"
              ]
          },
          {
              "Sid"   : "WorkPermissions",
              "Effect": "Allow",
              "Action": [
                  "ec2:DescribeInstances",
                  "ec2:StopInstances",
                  "ec2:StartInstances"
              ],
              "Resource": "*"
          }
      ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda" {
  name       = "lambda-stop-start-ec2-role-policy-attach"
  roles      = [aws_iam_role.lambda.name]
  policy_arn = aws_iam_policy.lambda.arn
}

################################################################################
# Zip python code and create lambda function
################################################################################

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "lambda_function.zip"
  source {
    filename = "lambda_function.py"
    content  = file("${path.module}/lambda_function.py")
  }
}

resource "aws_lambda_function" "ec2_scheduler_function" {
  function_name    = "stop-start-ec2-instances"
  description      = "Lambda to stop/start EC2 Instances with specific Tag"
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.11"
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 10
  tags = merge(local.common_tags, {
    Name = "${var.naming_prefix}-rule"
  })

  environment {
    variables = {
      EC2TAG_KEY   = var.stopstart_tags["TagKEY"]
      EC2TAG_VALUE = var.stopstart_tags["TagVALUE"]
    }
  }
}

################################################################################
# Create cloudwatch log group for logging 
################################################################################

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.ec2_scheduler_function.function_name}"
  retention_in_days = 7
  tags = merge(local.common_tags, {
    Name = "${var.naming_prefix}-logs"
  })
}

################################################################################
# Create cloudwatch event rules for stop and start EC2 and set labmda function as taget
################################################################################

resource "aws_cloudwatch_event_rule" "ec2" {
  for_each            = local.scheduler_actions
  name                = "EC2-scheduler-trigger-to-${each.key}-ec2"
  description         = "Invoke Lambda via AWS EventBridge"
  schedule_expression = each.value
  tags = merge(local.common_tags, {
    Name = "${var.naming_prefix}-rule"
  })
}

################################################################################
# Create Lambda Permissions and Event sources
################################################################################
resource "aws_lambda_permission" "ec2" {
  for_each      = local.scheduler_actions
  statement_id  = "AllowExecutionFromEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_scheduler_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2[each.key].arn
}

resource "aws_cloudwatch_event_target" "ec2" {
  for_each = local.scheduler_actions
  rule     = aws_cloudwatch_event_rule.ec2[each.key].name
  arn      = aws_lambda_function.ec2_scheduler_function.arn
  input    = <<JSON
    {
        "operation":"${each.key}",
        "tagkey": "${var.darede_tags.TagKEY}",
        "tagvalue": "${var.darede_tags.TagVALUE}"
        

    }
JSON
}

resource "aws_key_pair" "chaveSSH" {
  key_name   = "iac-dev"
  public_key = file("iac-dev.pub")

}