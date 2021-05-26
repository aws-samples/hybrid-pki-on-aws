## Hybrid PKI on AWS

TODO: Fill this README out!

Be sure to:

* Change the title in this README
* Edit your repository description on GitHub

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

The solution uses an offline root CA that can be operated on-premises or in an Amazon VPC, while the subordinate Windows CAs run on EC2 instances and are integrated with CloudHSM for key management and storage. To insulate the PKI from external access, the CloudHSM cluster are deployed in protected subnets, the EC2 instances are deployed in private subnets, and the host VPC has site-to-site network connectivity to the on-premises network. The Amazon EC2 volumes are encrypted with AWS KMS customer managed keys. Users and devices connect and enroll to the PKI interface through a Network Load Balancer.

This solution also includes a subordinate ACM private CA to issue certificates that will be installed on AWS services that are integrated with ACM. For example, ELB, CloudFront, and API Gateway. This is so that the certificates users see are always presented from your organization’s internal PKI.

**Prerequisites for deploying this hybrid internal PKI in AWS**
Experience with AWS Cloud, Windows Server, and AD CS is necessary to deploy and configure this solution.
An AWS account to deploy the cloud resources.
An offline root CA, running on Windows 2016 or newer, to sign the CloudHSM and the issuing CAs, including the private CA and Windows CAs. Here is an AWS Quick-Start article to deploy your Root CA in a VPC. We recommend installing the Windows Root CA in its own AWS account.
A VPC with at least four subnets. Two or more public subnets and two or more private subnets, across two or more AZs, with secure firewall rules, such as HTTPS to communicate with your PKI web servers through a load balancer, along with DNS, RDP and other port to communicate within your organization network. You can use this CloudFormation sample VPC template to help you get started with your PKI VPC provisioning.
Site-to-site AWS Direct Connect or VPN connection from your VPC to the on-premises network and other VPCs to securely manage multiple networks.
Windows 2016 EC2 instances for the subordinate CAs.
An Active Directory environment that has access to the VPC that hosts the PKI servers. This is required for a Windows Enterprise CA implementation.
Deploy the solution
The below CloudFormation Code and instructions will help you deploy and configure all the AWS components shown in the above architecture diagram. To implement the solution, you’ll deploy a series of CloudFormation templates through the AWS Management Console.

If you’re not familiar with CloudFormation, you can learn about it from Getting started with AWS CloudFormation. The templates for this solution can be deployed with the CloudFormation console, AWS Service Catalog, or a code pipeline.

**Download and review the template bundle**
To make it easier to deploy the components of this internal PKI solution, you download and deploy a template bundle. The bundle includes a set of CloudFormation templates, and a PowerShell script to complete the integration between CloudHSM and the Windows CA servers.

There are additional costs for resources deployed by this solution. The resources include: CloudHSM, ACM PCA, ELB, EC2s, S3, and KMS.
The solution also deploys some AWS Identity and Access Management (IAM) roles and policies.
To download the template bundle
Download or clone the solution source code repository from AWS GitHub.
Review the descriptions in each template for more instructions.
Deploy the CloudFormation templates
Now that you have the templates downloaded, use the CouldFormation console to deploy them.

**Deploy this template into an existing VPC to create the protected subnets to deploy a CloudHSM cluster.**

Navigate to the CloudFormation console.
Select the appropriate AWS Region, and then choose Create Stack.
Choose Upload a template file.
Select 01_PKI_Automated-VPC_Modifications.yaml as the CloudFormation stack file, and then choose Next.
On the Specify stack details page, enter a stack name and the parameters. Some parameters have a dropdown list that you can use to select existing values.
Choose Next, Next, and Create Stack.

**To deploy the PKI CDP S3 bucket template**

This template creates an S3 bucket for the CRL and AIA distribution point, with initial bucket policies that allow access from the PKI VPC, and PKI users and devices from your on-premises network, based on your input. To grant access to additional AWS accounts, VPCs, and on-premises networks, please refer to the instructions in the template.
Navigate to the CloudFormation console.
Choose Upload a template file.
Select 02_PKI_Automated-Central-PKI_CDP-S3bucket.yaml as the CloudFormation stack file, and then choose Next.
On the Specify stack details page, enter a stack name and the parameters.
Choose Next, Next, and Create Stack


**To deploy the ACM Private CA subordinate template**

This step provisions the ACM private CA, which is signed by an existing Windows root CA. Provisioning your private CA with CloudFormation makes it possible to sign the CA with a Windows root CA.

Navigate to the CloudFormation console.
Choose Upload a template file.
Select 03_PKI_Automated-ACMPrivateCA-Provisioning.yaml as the CloudFormation stack file, and then choose Next.
On the Specify stack details page, enter a stack name and the parameters. Some parameters have a dropdown list that you can use to select existing values.
Choose Next, Next, and Create Stack.


To deploy the Network Load Balancer template
In this step, you provision a Network Load Balancer.

**Navigate to the CloudFormation console.**

Choose Upload a template file.
Select 05_PKI_Automated-LoadBalancer-Provisioning.yaml as the CloudFormation stack file, and then choose Next.
On the Specify stack details page, enter a stack name and the parameters. Some parameters are filled in automatically or have a dropdown list that you can use to select existing values.
Choose Next, Next, and Create Stack.


**To deploy the HTTPS listener configuration template**

The following steps create the HTTPS listener with an initial configuration for the load balancer.

Navigate to the CloudFormation console:
Choose Upload a template file.
Select 06_PKI_Automated-HTTPS-Listener.yaml as the CloudFormation stack file, and then choose Next.
On the Specify stack details page, enter the stack name and the parameters. Some parameters are filled in automatically or have a dropdown list that you can use to select existing values.
Choose Next, Next, and Create Stack.

**To deploy the AWS KMS CMK template**

In this step, you create an AWS KMS CMK to encrypt EC2 EBS volumes and other resources. This is required for the EC2 instances in this solution.

Open the CloudFormation console.
Choose Upload a template file.
Select 04_PKI_Automated-KMS_CMK-Creation.yaml as the CloudFormation stack file, and then choose Next.
On the Specify stack details page, enter a stack name and the parameters.
Choose Next, Next, and Create Stack.

**To deploy the Windows EC2 instances provisioning template**

This template provisions a purpose-built Windows EC2 instance within an existing VPC. It will provision an EC2 instance for the Windows CA, with KMS to encrypt the EBS volume, an IAM instance profile and automatically installs SSM agent on your instance.

It also has optional features and flexibilities. For example, the template can automatically create new target group, or add instance to existing target group. It can also configure listener rules, create Route 53 records and automatically join an Active Directory domain.

Note: The AWS KMS CMK and the IAM role are required to provision the EC2, while the target group, listener rules, and domain join features are optional.

Navigate to the CloudFormation console.
Choose Upload a template file.
Select 07_PKI_Automated-EC2-Servers-Provisioning.yaml as the CloudFormation stack file, and then choose Next.
On the Specify stack details page, enter the stack name and the parameters. Some parameters are filled in automatically or have a dropdown list that you can use to select existing values.
Note: The Optional properties section at the end of the parameters list isn’t required if you’re not joining the EC2 instance to an Active Directory domain.

Choose Next, Next, and Create Stack.

**To integrate CloudHSM cluster to Windows Server AD CS**

Open the script 09_PKI_AWS_CloudHSM-Windows_CA-Integration-Playbook.txt and follow the instructions to complete the CloudHSM integration with the Windows servers.
