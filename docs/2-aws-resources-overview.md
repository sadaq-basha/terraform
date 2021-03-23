# AWS resources overview

All AWS resources are created in `ap-northeast-1` zone.

All zoned resources are placed in `ap-northeast-1a` zone for the seamless integration with Kubernetes orchestration.

## Networking

Terraform configuration creates two networks:

* private - Used for internal cluster communication, DB connections.
* public - Used for routing connections outside cluster.

All databases are using DB - subnet group attached to private subnet for communication with cluster.

Security groups:

* EKS internal security group. Security group which is attached to all worker nodes and DBs in setup. Security group only allows communication between members of this security group.

* LoadBalancers security groups. This security groups are managed by Kubernetes. Load balancers are attached via public subnet routing and security group allowing communication between specific load balancer port and cluster workload port. In current state cluster has two load balancers in use: Primary ingress balancer and MQTT balancer. MQTT balancer exposes 1885 port for the MQTT instances, Ingress load balancer exposes ports 80 and 443.

  

Communication with resources outside cluster are managed by NAT gateway.

## Databases

Current setup uses the following managed databases:

* MongoDB (MongoDB 3.6 compatible)
* MariaDB 10.3

Aligned with those ElastiCache Redis(version 3.2.10) is used for caching.

## Other managed services

AWS Cloudwatch Logs is used to store cluster workloads logs. Configuration creates `/aws/eks/{cluster_name}/pods` log group for cluster.

AWS ECR is used to store docker images for cluster.

## AWS EKS

EKS - Elastic Kubernetes Service.

Cluster is using the following AWS resources:

* AWS Cloudwatch - Uses `/aws/eks/{cluster_name}/cluster`(e.g. `/aws/eks/dev/cluster` for cluster named`dev` ) for storing kubernetes management logs. 
* AWS LoadBalancing - Uses dynamically created load balancers for service type `LoadBalancer` in Kubernetes resources.
* AWS ASG - Kubernetes workers are deployed as a set of Autoscaling groups. There are two available scaling groups: demand and spot nodes. Key difference between them is running costs, spot nodes are often x2-3 lower in price than demand nodes. ASGs are managed by `cluster-autoscaler` component which is described in `kubernetes-resources` doc.
* AWS IAM - IAM users are mapped to Kubernetes RBAC policies as defined in Terraform configuration.

### EKS worker nodes

Workers nodes configured without having any SSH keys attached. This is intentional prior to Kubernetes management best-practices.
Best practice for Kubernetes workers nodes is to make them as similar as possible(via ASG for example) and to manage them only via Kubernetes manifests.
This approach is used to achieve great cluster scalability and stability over time.

## Terraform

All editable terraform variables are defined in the `/terraform/variables.tf` file. Variables allows to change key parameters for cluster configuration:

* Machines sizes to use. Variables which have limitation for specific machines version have comment with the list of available machine sizes.
* Number of worker machines to use.
* Default tags which will be assigned to all created resources.
* IAM users mapping for the cluster resources.

As soon as Terraform artifacts contains sensitive data they are not stored in VCS and will be provided separately.

