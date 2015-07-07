##2.2.2 Obtain a full description of the Processor instance

aws ec2 describe-instances --filter 'Name=tag:Name,Values=Processor'

#2.2.3 Refine description to include only VolumeId of Amazon EBS volume

aws ec2 describe-instances --filter 'Name=tag:Name,Values=Processor' --query 'Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.{VolumeId:VolumeId}'

#2.2.4 Obtain instance ID of Processor instance

aws ec2 describe-instances --filters 'Name=tag:Name,Values=Processor' --query 'Reservations[0].Instances[0].InstanceId'

#2.2.5 Stop Processor instance

#aws ec2 stop-instances --instance-ids <instance-id>
aws ec2 stop-instances --instance-ids "i-ea821a40"

#2.2.6 Check status of stop action

#aws ec2 describe-instance-status --instance-id <instance-id>
aws ec2 describe-instance-status --instance-id "i-ea821a40"

#2.2.7 Create first snapshot

#aws ec2 create-snapshot --volume-id <volume-id>
aws ec2 create-snapshot --volume-id "vol-cbc9d9dc"

#2.2.8 Report on snapshot status

#aws ec2 describe-snapshots --snapshot-id <snapshot-id>
aws ec2 describe-snapshots --snapshot-id "snap-6e5a3638"

#2.2.9 Restart Processor instance

#aws ec2 start-instances --instance-ids <instance-id>
aws ec2 start-instances --instance-ids "i-ea821a40"

#2.2.10 Check status of start action

#aws ec2 describe-instance-status --instance-id <instance-id>
aws ec2 describe-instance-status --instance-id "i-ea821a40"





