variable "lambda_name" {
  type = string
}

variable "scaling_configuration_path" {
  type = string
}

variable "schedule_expression" {
  type = string
}

variable "target_cluster" {
  type = string
  default = ""
}

resource "aws_iam_policy" "allow_modify_describe" {
  description = "Allows lambda ${var.lambda_name} to describe all rds clusters and modify them."
policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "rds:ModifyDBCluster"
        ],
        "Resource": [
          "*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "rds:DescribeDBClusters"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  }
)
}

module "lambda"{
  source           = "github.com/moritzzimmer/terraform-aws-lambda?ref=v5.4.0"
  filename         = data.archive_file.archive.output_path
  function_name    = var.lambda_name
  handler          = "script.handler"
  runtime          = "python3.7"
  source_code_hash = data.archive_file.archive.output_base64sha256
  event = {
    type                = "cloudwatch-event"
    schedule_expression = var.schedule_expression
  }
  environment      = {variables:{"TARGET_CLUSTER":var.target_cluster}}

}

data "template_file" "config" {
  template = file(var.scaling_configuration_path)
}

data "template_file" "script" {
  template = file("${path.module}/script.py")
}


data "archive_file" "archive" {
  type        = "zip"
  output_path = "archive.zip"
  source {
    content  = data.template_file.config.rendered
    filename = "config.json"
  }
  source {
    content  = data.template_file.script.rendered
    filename = "script.py"
  }
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = module.lambda.role_name
  policy_arn = aws_iam_policy.allow_modify_describe.arn
}
