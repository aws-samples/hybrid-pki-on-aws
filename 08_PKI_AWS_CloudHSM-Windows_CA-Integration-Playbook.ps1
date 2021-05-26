# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0


#Before you begin, go to the AWS console and add the cloudhsm security group to the ADCS Server
#Login to the appropriate ADCS Server

#Open Powsershell as Adminstrator
#Set installer and log file location
$hsminstaller = "C:\ProgramData\Amazon\CloudHSM"
Start-Transcript -Path $hsminstaller\UserDataOutput.log

#Download and install CloudHSM client
Invoke-WebRequest ` https://s3.amazonaws.com/cloudhsmv2-software/CloudHsmClient/Windows/AWSCloudHSMClient-latest.msi ` -OutFile $hsminstaller\AWSCloudHSMClient-latest.msi

Start-Process ` -FilePath $hsminstaller\AWSCloudHSMClient-latest.msi
#Accept License agreement 

#At this point, rename the RootCA certificate(used to initialize the HSM)  to (customerCA.crt) and store a copy to "C:\ProgramData\Amazon\CloudHSM"

#Add the cloudhsm cluster IP
$hsmconfigdir = "C:\Program Files\Amazon\CloudHSM"
cd $hsmconfigdir
.\configure.exe -a <HSMIPAddress>

#Verify the service is running
Get-Service AWSCloudHSMClient

#Start the HSM client service
$hsmconfigdir = "C:\Program Files\Amazon\CloudHSM"
cd $hsmconfigdir
net.exe start AWSCloudHSMClient

#Verify the service is running
Get-Service AWSCloudHSMClient

#Test cloudHSM cluster connection
$hsmconfigdir = "C:\Program Files\Amazon\CloudHSM"
cd $hsmconfigdir
.\cloudhsm_mgmt_util.exe C:\ProgramData\Amazon\CloudHSM\data\cloudhsm_mgmt_util.cfg
#exit out of cloudhsm (with "quit" command)

#Synchronize the HSMs in the cluster
$hsmconfigdir = "C:\Program Files\Amazon\CloudHSM"
cd $hsmconfigdir
.\configure.exe -m

#Test cloudHSM cluster connection
$hsmconfigdir = "C:\Program Files\Amazon\CloudHSM"
cd $hsmconfigdir
.\cloudhsm_mgmt_util.exe C:\ProgramData\Amazon\CloudHSM\data\cloudhsm_mgmt_util.cfg
#exit out of cloudhsm (with "quit" command)

#Verify that these providers are available (Cavium CNG Provider and Cavium Key Storage Provider)
$hsmconfigdir = "C:\Program Files\Amazon\CloudHSM"
cd $hsmconfigdir
.\ksp_config.exe -enum 
.\cng_config.exe -enum

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
Required for first time setup ONLY!
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

#Now connect to the Cloud HSM using End-to-end encryption

$hsmconfigdir = "C:\Program Files\Amazon\CloudHSM"
cd $hsmconfigdir
.\cloudhsm_mgmt_util.exe C:\ProgramData\Amazon\CloudHSM\data\cloudhsm_mgmt_util.cfg

#Use the enable_e2e command to enable end-to-end encryption. (if necessary)
enable_e2e

#Use the listUsers command to display the existing users.
listUsers

#Use the loginHSM command to log in to the HSM as the PRECO user. This is a temporary user that exists on the first HSM in your cluster.
loginHSM PRECO admin password
#Use the changePswd command to change the password for the PRECO user. When you change the password, the PRECO user becomes a crypto officer (CO).
changePswd PRECO admin <NewPassword>

Do you want to continue(y/n)?y
#Use the listUsers command to verify that the user's type changed to crypto officer (CO).
listUsers

#Use the quit command to stop the cloudhsm_mgmt_util tool.
quit

#Create Additional HSMs in your cluster:

#Log back into the CloudHSM
$hsmconfigdir = "C:\Program Files\Amazon\CloudHSM"
cd $hsmconfigdir
.\cloudhsm_mgmt_util.exe C:\ProgramData\Amazon\CloudHSM\data\cloudhsm_mgmt_util.cfg

loginHSM CO admin <NewPassword>
loginHSM CO example_user <NewPassword>

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
#Cheat sheet for managing HSM Users

#Use these commands to manage users (create, update and delete) a user on the HSM. The following examples manage CO and CU users
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
createUser CO example_officer <NewPassword>
createUser CU example_user <NewPassword>
changePswd CO example_officer <new password>
changePswd CU example_user <new password>
deleteUser CO example_officer
deleteUser CU example_user
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#
#Perform the below steps to Create/Update bridge between ADCS and CloudHSM
#Go to the C:\Program Files\Amazon\CloudHSM\tools\ folder.

#Run the set_cloudhsm_credentials.exe file with the CU username and password parameters.
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-#

$hsmconfigtools = "C:\Program Files\Amazon\CloudHSM\tools"
cd $hsmconfigtools
.\set_cloudhsm_credentials.exe --username example_user --password hsmPassWord123

changePswd CU example_user hsmPassWord2468!!
createUser CO example_user hsmPassWord123!

$hsminstaller = "C:\ProgramData\Amazon\CloudHSM"
Invoke-WebRequest ` https://live.sysinternals.com/psexec.exe ` -OutFile $hsminstaller\psexec.exe

Start-Process ` -FilePath $hsminstaller\psexec.exe

#Open CMD as Administrator
> whoami
cd "C:\ProgramData\Amazon\CloudHSM"
PsExec.exe -i -s %SystemRoot%\System32\cmd.exe

#Type whoami in the new terminal and ensure it is the nt user 
C:\Windows\system32>Whoami
nt authority\system

cd "C:\ProgramData\Amazon\CloudHSM"

psexec.exe -s "C:\Program Files\Amazon\CloudHsm\tools\set_cloudhsm_credentials.exe" --username example_user --password hsmPassWord123

#NOTE:

#1. Create a dedicated Crypto User (CU) as a service account, and placed in "Windows Credential Manager (WCM)" - for each Windows CA integration (1 CU to 1 Windows Server). 
#2. CU HSM session termination is required for password change. That means the CA needs to be shutdown for password rotation.
#------ Doing #1 will allow regular password rotation without any interuption.

#3. Create a Windows Active Directory Service account for (Enterprise CA) PKI installation and configurations. 
#4. CloudHSM to windows CA integration requires; One WCM service credentials, 1. as the NT system user, and Two by an interactive Windows account.
#----- Doing #3 & #4 will all Windows CA to automatically sync the HSMs when/if they get replaced during active operations. 