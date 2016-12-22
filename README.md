# Overview
This document outlines the steps/procedures taken to design, implement and manage a development AWS environment/architecture for the purposes of introducing a new Technical Account Manager (TAM) to AWS for the purposes of his/her development plan. The architecture of choice is an Internet of Things (IoT) pipeline that will evolve over three phases:
#### Phase 1: Legacy
This phase will involve initially porting the legacy Data Science “Sandbox” (https://github.com/darkreapyre/Sandbox” onto AWS.
#### Phase 2: Containerize
This phase involves taking said architecture and porting it from an infrastructure-based (IaaS) cloud to Docker containers.
#### Phase 3: Serverless
This phase will involve leveraging the various comparable AWS platforms to fully incorporate the solution into AWS by leveraging the various service offerings.
These phases will be implemented by leveraging a number of Infrastructure as Code (IaC) tools in order to simulate any potential customer implementation scenarios:
1. Vagrant
2. Ansible
3. CloudFormation
4. TerraForm
Additionally, the objective of this implementation is to leverage the Command-line (CLI) tools, scripts and an AWS WorKSpaces in order to provide an advanced user experience over the AWS Console.

#### Pre-requisites

To start, the following components must be configured or installed.
1. AWS Account.
2. AWS WorkSpaces desktop: This avoids ubiquity or working behinds firewalls/proxies etc. and allows a simulated approach to a customers’ environment. 
3. AWS Command Line Interface (CLI) for Windows.
>Note: When installing the 64-bit AWS CLI on AWS WorkSpaces, there may be errors citing code 2503. These errors can be corrected by [this](http://winaero.com/blog/fix-msi-installer-errors-2502-and-2503-in-windows-10-windows-8-1-and-windows-7/) procedure .
4. [Git client for Windows](https://git-scm.com/).
5. [PuTTY and PuTTYgen](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html).