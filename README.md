# terraform-scale-rds-dbcluster
This is a simple module which allows you to generate lambdas triggered by cloudwatch schedule expressions to apply a ScalingConfiguration change to your rds clusters.

Example module to scale RDS clusters down every Friday at 10pm
```hcl
module "scale_rds_down" {
    source = "github.com/GregoryWiltshire/terraform-scale-rds-dbcluster"
    lambda_name = "scale_rds_down"
    schedule_expression = "cron(0 22 ? * FRI *)"
    scaling_configuration_path = "config.json"
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| lambda_name | Name for your lambda. | `string` | `""` | yes |
| scaling_configuration_path | Path to your json [scaling configuration](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/rds.html#RDS.Client.modify_db_cluster). | `string` | n/a | yes |
| schedule_expression | The AWS [cloudwatch events](https://docs.aws.amazon.com/lambda/latest/dg/services-cloudwatchevents-expressions.html) expression to trigger your scaling config change. | `string` | n/a | yes |
| target_cluster | Target a single cluster by it's dbclusterid | `string` | `""` | no |

