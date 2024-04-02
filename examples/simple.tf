data "aws_default_tags" "tags" {}

module "anomaly_alarm" {
  source                      = "../"
  account_name                 = "infrademo"
  env                         = "test"
}
