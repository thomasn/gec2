class aws::ruby {
  ruby::gem { [ "aws-sdb", "aws-s3", "amazon-ec2", "SQS" ]:
    require => Class["ruby"]
  }
}
