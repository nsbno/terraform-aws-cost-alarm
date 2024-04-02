# terraform-aws-cost-alarm

Module for setting a anomaly-based cost alarm and integrating it with a central pagerduty 
alarm

# Usage
To use this module, just add it to your terraform (in this case, `-aws` repo).
    
```hcl
module "anomaly_alarm" {
  source                      = "github.com/nsbno/terraform-aws-cost-alarm?ref=x.y.z"
  account_name                = "infrademo"
  env                         = "test"
}
```

