#!/bin/bash
# Copy Livy from S3
aws s3 cp s3://chkrd/artifacts/livy-server-0.3.0.zip /home/hadoop/
unzip /home/hadoop/livy-server-0.3.0.zip
rm /home/hadoop/livy-server-0.3.0.zip

# Copy Configuration files
aws s3 cp s3://chkrd/artifacts/livy.conf /home/hadoop/livy-server-0.3.0/conf/
aws s3 cp s3://chkrd/artifacts/livy-env.sh /home/hadoop/livy-server-0.3.0/conf/

# Start Livy
nohup /home/hadoop/livy-server-0.3.0/bin/livy-server > /tmp/livy.log 2>&1 &