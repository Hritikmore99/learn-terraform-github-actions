# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_emr_cluster" "cluster" {
  name          = "emr-test-arn"
  release_label = "emr-6.12.0"
  applications  = ["Spark"] #change -->EMR subnetID 

  additional_info = <<EOF
{
  "instanceAwsClientConfiguration": {
    "proxyPort": 8099,
    "proxyHost": "myproxy.example.com"
  }
}
EOF

  termination_protection            = false
  keep_job_flow_alive_when_no_steps = true

  ec2_attributes {
    subnet_id                         = "subnet-03d0afe4b2fd49e84"  #change -->EMR subnetID 
    emr_managed_master_security_group = "sg-0fca9573e6faf69b4"  	#change -->EMR primary node SG ID
    emr_managed_slave_security_group  = "sg-04c5455cf7f81e274"  	#change -->EMR core node SG ID
    instance_profile                  = "arn:aws:iam::486541654673:instance-profile/EMR_EC2_DefaultRole" 
	#change -->go to IAM role check EMR_EC2_DefaultRole instance_profile ARN
  }
 
  master_instance_group {
    instance_type = "m4.large" #change here
  }

  core_instance_group {
    instance_type  = "m5.xlarge" #change here
    instance_count = 1

    ebs_config {
      size                 = "40" #change here
      type                 = "gp2"
      volumes_per_instance = 1
    }

    bid_price = "0.30"
  }

  ebs_root_volume_size = 15 #change here

  tags = {
    role = "rolename"
    env  = "env"
  }


  configurations_json = <<EOF
  [
    {
      "Classification": "hadoop-env",
      "Configurations": [
        {
          "Classification": "export",
          "Properties": {
            "JAVA_HOME": "/usr/lib/jvm/java-1.8.0"
          }
        }
      ],
      "Properties": {}
    },
    {
      "Classification": "spark-env",
      "Configurations": [
        {
          "Classification": "export",
          "Properties": {
            "JAVA_HOME": "/usr/lib/jvm/java-1.8.0"
          }
        }
      ],
      "Properties": {}
    }
  ]
EOF

  service_role = "arn:aws:iam::486541654673:role/EMR_DefaultRole" 
  #change -->go to IAM role check EMR_DefaultRole ARN
}