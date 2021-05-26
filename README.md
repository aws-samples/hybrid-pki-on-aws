## Hybrid PKI on AWS

TODO: Fill this README out!

Be sure to:

* Change the title in this README
* Edit your repository description on GitHub

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.


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
