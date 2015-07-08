Start-Transcript -Path C:\Users\Administrator\gitrepos\awscourse\Lab6W\Lab6W.transcript

get-content C:\temp\UserData.txt

$amiid = "ami-c1740ab6"
$subnetid = "subnet-d7c6a2a0"
$kp = "qwikLABS-L405-10674"
$sgid = "sg-a0c5c8c5"

#==================================================================================================================
#1.4 Create New EC2 Instance
#==================================================================================================================

#1.4.3 Create your new EC2 instance

#aws ec2 run-instances --key-name [key-name] --instance-type t2.micro --image-id [ami-id] --user-data file://c:\temp\UserData.txt --security-group-ids [sg-id] --subnet-id [subnet-id] --associate-public-ip-address
aws ec2 run-instances --key-name $kp --instance-type t2.micro --image-id $amiid --user-data file://c:\temp\UserData.txt --security-group-ids $sgid --subnet-id $subnetid --associate-public-ip-address
$instanceid = "i-3138399b"

#1.4.4 Monitor the instance status

aws ec2 describe-instance-status --instance-id $instanceid
aws ec2 describe-instances --instance-id $instanceid --query 'Reservations[*].Instances[*].{InstanceId,Placement.AvailabilityZone}'

#1.4.5 Obtain public DNS name of new Web server

$publicdnsname = aws ec2 describe-instances --instance-id $instanceid --query 'Reservations[0].Instances[0].NetworkInterfaces[0].Association.PublicDnsName'
$publicdnsname = $publicdnsname -replace '"',''


#1.4.6 Test Web server using PowerShell

(new-object net.webclient).DownloadString("http://$publicdnsname/stressapp/Default")

#==================================================================================================================
#1.5 Create a Custom AMI
#==================================================================================================================


#1.5.1 Create a new AMI based on the new instance

aws ec2 create-image --name WebServer --instance-id $instanceid

$newami = "ami-b6f9bbc1"