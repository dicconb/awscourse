##2.2.2 Obtain a full description of the Processor instance

aws ec2 describe-instances --filter 'Name=tag:Name,Values=Processor'

#2.#2.3 Refine description to include only VolumeId of Amazon EBS volume

aws ec2 describe-instances --filter 'Name=tag:Name,Values=Processor' --query 'Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.{VolumeId:VolumeId}'

#2.#2.4 Obtain instance ID of Processor instance

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


<#


==================================================================================================================
#2.3 Schedule Creation of Subsequent Snapshots
==================================================================================================================

#2.3.1 Execute the following command

#>

type C:\Users\Administrator\.aws\config

#2.3.3 Create backup.bat

#aws ec2 create-snapshot --volume-id <volume-id> --region <region> >c:\temp\output.txt 2>&1
aws ec2 create-snapshot --volume-id "vol-cbc9d9dc" --region "eu-west-1" >c:\temp\output.txt 2>&1
'aws ec2 create-snapshot --volume-id "vol-cbc9d9dc" --region "eu-west-1" >c:\temp\output.txt 2>&1' | out-file  -file "C:\temp\backup.bat" -Encoding ascii

#2.3.4 Create batch logon user

net user backupuser passw0rd! /ADD

#2.3.5 Grant backupuser batch logon privileges

c:\temp\ntrights +R SeBatchLogonRight -u backupuser

#2.3.6 Schedule task

schtasks /create /sc MINUTE /mo 1 /tn "Volume Backup Task" /ru backupuser /rp passw0rd! /tr c:\temp\backup.bat

#2.3.7 Verify that snapshots are being created

#aws ec2 describe-snapshots --filters "Name=volume-id,Values=<volume-id>"
get-date | out-default;aws ec2 describe-snapshots --filters "Name=volume-id,Values=vol-cbc9d9dc"

<#
==================================================================================================================
#2.4 Retain Only Last Two Snapshots
==================================================================================================================

#2.4.1 Remove scheduled tasks
#>
schtasks /Delete /tn "Volume Backup Task"

#2.4.3 Verify the current number of snapshots for the volume

#aws ec2 describe-snapshots --filters "Name=volume-id,Values=<volume-id>" --query 'Snapshots[*].SnapshotId'
aws ec2 describe-snapshots --filters "Name=volume-id,Values=vol-cbc9d9dc" --query 'Snapshots[*].SnapshotId'

#2.4.4 Execute snapshotter.ps1

#c:\temp\snapshotter.ps1 <region>
c:\temp\snapshotter.ps1 "eu-west-1"

#2.4.5 Re-examine the current number of snapshots for the volume

#aws ec2 describe-snapshots --filters "Name=volume-id,Values=<volume-id>" --query 'Snapshots[*].SnapshotId'
aws ec2 describe-snapshots --filters "Name=volume-id,Values=vol-cbc9d9dc" --query 'Snapshots[*].SnapshotId'

<#
==================================================================================================================
#3.2 Move a Log File into Amazon S3
==================================================================================================================
#>

#3.2.1 Configure the AWS CLI

aws configure

#3.2.3 Download loggen.sh

(New-Object System.Net.WebClient).DownloadFile("https://d2lrzjb0vjvpn5.cloudfront.net/sys-ops/v2.2/lab-3-storage-windows/static/loggen.ps1", "c:\temp\loggen.ps1")

#3.2.4 Run loggen.ps1

#c:\temp\loggen.ps1
invoke-command -computername . {c:\temp\loggen.ps1} -AsJob


#3.2.7 Change directories

cd \temp

#3.2.8 Move file into Amazon S3

aws s3 mv timestamp.log "s3://dicconlab3w/logfiles/timestamp-$(Get-Date -Format 'M-d-yyyy-h:m:s')"

#3.2.9 Move file again

aws s3 mv timestamp.log "s3://dicconlab3w/logfiles/timestamp-$(Get-Date -Format 'M-d-yyyy-h:m:s')"

#3.2.10 List the contents of your Amazon S3 bucket

aws s3 ls s3://dicconlab3w

#3.2.11 List all objects containing the /logfiles/ prefix

aws s3 ls s3://dicconlab3w/logfiles/

#3.2.12 Move oldest file to /logfiles/archive/ prefix

aws s3 mv s3://dicconlab3w/logfiles/timestamp-7-7-2015-1:18:11 s3://dicconlab3w/logfiles/archive/timestamp-7-7-2015-1:18:11

#3.2.13 Verify move

aws s3 ls s3://dicconlab3w/logfiles/
aws s3 ls s3://dicconlab3w/logfiles/archive/

get-job * | Stop-Job



<#

++++4. Challenge Solution - Synchronize Folder with Amazon S3++++

==================================================================================================================
4.1 Download and Unzip Sample Files
==================================================================================================================
#>
#4.1.1 Download files

(New-Object System.Net.WebClient).DownloadFile("https://d2lrzjb0vjvpn5.cloudfront.net/sys-ops/v2.2/lab-3-storage-windows/static/files.zip", "c:\temp\files.zip")

aws s3api --help

"manually enabling versioning"

cd C:\temp
gci -Recurse

aws s3 ls s3://dicconlab3w/MyTempFolder
aws s3 sync c:\temp\ s3://dicconlab3w/MyTempFolder

aws s3 ls s3://dicconlab3w/MyTempFolder/

aws s3 ls s3://dicconlab3w/MyTempFolder/files/
