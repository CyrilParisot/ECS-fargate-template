#!/bin/bash

aws cloudformation delete-stack --stack-name application-demo 

aws cloudformation wait stack-delete-complete --stack-name application-demo

aws cloudformation delete-stack --stack-name sharedInfra 
