Start-Transcript -Path C:\Users\Administrator\gitrepos\awscourse\Lab5W\Lab5W.transcript


#==================================================================================================================
#1.2 Find Development Instances for Project
#==================================================================================================================

#1.2.2 Find all instances in account with a tag named Project, and a value of ERPSystem

aws ec2 describe-instances --filter "Name=tag:Project,Values=ERPSystem"

#1.2.3 Limit output of above command to InstanceId

aws ec2 describe-instances --filter "Name=tag:Project,Values=ERPSystem" --query 'Reservations[*].Instances[*].InstanceId'

#1.2.4 Include multiple selected values in command output

aws ec2 describe-instances --filter "Name=tag:Project,Values=ERPSystem" --query 'Reservations[*].Instances[*].{ID:InstanceId,AZ:Placement.AvailabilityZone}'

#1.2.5 Include the Project tag in the output

aws ec2 describe-instances --filter "Name=tag:Project,Values=ERPSystem" --query 'Reservations[*].Instances[*].{ID:InstanceId,AZ:Placement.AvailabilityZone,Project:Tags[?Key==`Project`] | [0].Value}'

#1.2.6 Include the Environment and Version tags in the output 

aws ec2 describe-instances --filter "Name=tag:Project,Values=ERPSystem" --query 'Reservations[*].Instances[*].{ID:InstanceId,AZ:Placement.AvailabilityZone,Project:Tags[?Key==`Project`] | [0].Value,Environment:Tags[?Key==`Environment`] | [0].Value,Version:Tags[?Key==`Version`] | [0].Value}'

#1.2.7 Add an additional filter to restrict the return results to instances whose Environment tag is set to development:

aws ec2 describe-instances --filter "Name=tag:Project,Values=ERPSystem" "Name=tag:Environment,Values=development" --query 'Reservations[*].Instances[*].{ID:InstanceId,AZ:Placement.AvailabilityZone,Project:Tags[?Key==`Project`] | [0].Value,Environment:Tags[?Key==`Environment`] | [0].Value,Version:Tags[?Key==`Version`] | [0].Value}'


#==================================================================================================================
#1.3 Change Version Tag for Development Instances
#==================================================================================================================

#1.3.3 Run Powershell script to change Version tag on select instances

get-content "C:\temp\change-resource-tags.ps1"

C:\temp\change-resource-tags.ps1


#1.3.4 Verify changes

aws ec2 describe-instances --filter "Name=tag:Project,Values=ERPSystem" --query 'Reservations[*].Instances[*].{ID:InstanceId,AZ:Placement.AvailabilityZone,Project:Tags[?Key==`Project`] | [0].Value,Environment:Tags[?Key==`Environment`] | [0].Value,Version:Tags[?Key==`Version`] | [0].Value}'


#++++2. Stop and Start Resources by Tag++++


#==================================================================================================================
#2.2. Stop and Restart ERPProject Development Instances
#==================================================================================================================

#2.2.1 Stop all development instances for the ERPSystem project

Get-Content "c:\temp\stopinator.ps1"
c:\temp\stopinator.ps1 -tags "Project=ERPSystem;Environment=development"

#2.2.6 Restart the development instances for the ERPSystem project

c:\temp\stopinator.ps1 -tags "Project=ERPSystem;Environment=development" -start


#++++3. Challenge 1 Solution - Terminate Non-Compliant Instances++++

#==================================================================================================================
#3.3. Run the Script
#==================================================================================================================

<#
My attempt before reading solution
#>

$allinstances = aws ec2 describe-instances | out-string | ConvertFrom-Json | select -expand reservations
$allinstances.count

$allinstances | ft -auto

$allinstances.instances | ft -auto

$allinstances.instances | select -first 1 | fl

$allinstances.instances | group-object subnetid

$allinstances = (aws ec2 describe-instances | out-string | ConvertFrom-Json).reservations.instances

$allinstances | group-object subnetid

$privatesubnetinstances = $allinstances | ?{$_.subnetid -eq "subnet-4b1ba512"}

$privatesubnetinstances | select -first 1

($privatesubnetinstances | select -first 1).Tags | gm

$privatesubnetinstances | %{($_.tags | ?{$_.key -eq "Environment"}).Value}

$privatesubnetinstances | %{($_.tags | ?{$_.key -eq "Environment"}).Value}

$privatesubnetinstances | ?{($_.tags.Key -notcontains "Environment")}

$privatesubnetinstances | %{($_.tags.Key)}


aws ec2 describe-instances --filter "Name=tag:Environment,Values=''" --query 'Reservations[*].Instances[*].{ID:InstanceId,AZ:Placement.AvailabilityZone}'















#3.3.4 Run the terminate-instance.php script

get-content "c:\temp\terminate-instances.ps1"

#c:\temp\terminate-instances.ps1 -region [region] -subnetid [subnet-id]
c:\temp\terminate-instances.ps1 -region "eu-west-1" -subnetid "subnet-4b1ba512"



#another crack (after removing a tag)
$allinstances = (aws ec2 describe-instances | out-string | ConvertFrom-Json).reservations.instances
$privatesubnetinstances = $allinstances | ?{$_.subnetid -eq "subnet-4b1ba512"}
$noncompliantinstances = $privatesubnetinstances | ?{($_.tags.Key -notcontains "Environment") -or (($_.tags | ?{$_.key -eq "Environment"}).Value -eq "")}
$noncompliantinstances | %{Get-EC2Instance -Instance $_.InstanceId -Region "eu-west-1"} | Stop-EC2Instance -Terminate -Region "eu-west-1"