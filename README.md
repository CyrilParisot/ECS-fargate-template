# Demo ECS fargate
This Repository contains a set of AWS CloudFormation samples to deploy ECS cluster

## Fargate (ECS) reminder
AWS Fargate is a technology for Amazon ECS that allows to run containers without having to manage servers or clusters.

- **Cluster**: a group of EC2 instances hosting containers (in fargate mode you will not be able to see or connect to them).
- **Task definition**: specification regarding how ECS should run your container. Here you define which image to use, port mapping, memory, environment variables, etc.
- **Service**: Services launch and maintain tasks running inside a cluster. A Service will auto-recover any stopped tasks keeping the number of tasks running as you specified.
  
# Architecture overview (demo)


The sample CloudFormation templates provision the network infrastructure and all the components shown in the architecture diagram. I broke the CloudFormation templates into the following two stacks.

1.	CloudFormation template to set up VPC, subnets, route tables, internet gateway, NAT gateway, interface endpoint, and other networking components.
2.	CloudFormation template to deploys an application container to an AWS ECS Fargate Cluster

The stacks are integrated using exported output values. Using two differents CloudFormation stacks instead of one nested stack gives you some flexibility. 
For example, you can choose to deploy the VPC CloudFormation stacks once and an application cluster CloudFormation stack multiple times in an AWS Region.
For every template you find informations of created object in the output section of Cloudformation. 


## Create shared infrastructure

This template deploys a VPC, with a pair of public and private subnets spread
across two Availability Zones. It deploys an internet gateway, with a default
route on the public subnets. It deploys a pair of NAT gateways (one in each AZ),
and default routes for them in the private subnets.
```sh
aws cloudformation create-stack --stack-name sharedInfra --template-body file://00_sharedinfrastructure.yaml
```

## Create an application container in ECS (Fargate)

This template deploys an application to an AWS ECS Fargate Cluster on sharedInfra VPC and Subnets.
An ECS service ensures an application continues to run on the created Cluster.
Logging is captured within CloudWatch.

```sh
aws cloudformation create-stack --stack-name application-demo --template-body file://01_ECS_Fargate_application_demo.yaml --capabilities CAPABILITY_IAM
```


## Update stack 

```sh
 aws cloudformation update-stack --stack-name application-demo --template-body file://01_ECS_Fargate_application_demo.yaml --capabilities CAPABILITY_NAMED_IAM 

 ```

## Test autoscaling 

if you are using image `cyparisot/consume-cpu:latest`
```sh
 curl --data "millicores=3000&durationSec=60" http://<<applicationlurl>>/ConsumeCPU 
 ```
 3000 millicores will be consumed for 60 seconds.  
 With several call new tasks willl be launch 


## Test service discovery 

To verify that your tasks can be resolved from your VPC, thanks to your service discovery, run the following commands:
```
 dig ExampleService.PrivateNamespace. +short
 dig srv ExampleService.PrivateNamespace. +short
 curl ExampleService.PrivateNamespace. -I
```
replace `PrivateNamespace` & `ExampleService` by values definie in your cfn template 

# Optimize part (Prod)
Before you use this template to be production ready, consider improving the
following:

- Use certificates and HTTPS protocol for ALB  
  see listenerHTTPS in cfn template
  

# Cleaning part
In order to properly delete your stacks, we advise that you run this bash script instead of trying to do it manually:
```sh
./delete.sh
```
