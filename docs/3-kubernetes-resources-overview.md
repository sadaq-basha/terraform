# Kubernetes cluster resources overview

## Software needed

* [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) 
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) version 1.13
* [Helm](https://helm.sh/docs/using_helm/#installing-the-helm-client) version 2.13.1

Kubernetes components are separated in two namespaces:
* configuration
* application.

## Kubernetes configuration namespace

Configuration namespace contains all generic components for cluster such as:
* cert-manager
* cluster-autoscaler
* fluentd-cloudwatch
* hive-mq
* jenkins
* kube-ops-view
* mailhog
* metrics-server
* nginx-ingress
* prometheus-operator
* rabbitmq-ha

Configuration for the following components is managed by using [Helm](https://helm.sh/docs/). 

All cluster charts are located at the `./kube/charts` directory.
Charts configuration are located at the appropriate locations at the `./kube/config`.

**Example**: `jenkins` chart location is `./kube/charts/jenkins`, jenkins configuration is located at `./kube/config/jenkins/values.yaml`.


## Kubernetes application namespace

Application namespace is used for the application deployment. 
It contains configuration values for application:
* confirmaps/external-resources - Contains all configurations related to the resources outside Kubernetes cluster.
* confirmaps/internal-resources - Referes to the resources inside Kubernetes cluster, such as RabbitMQ.
**Example**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: internal-resources
  namespace: application
data:
  # App Messaging
  APP_RABBITMQ_HOST: "rabbitmq-ha.b2b-network"
  APP_RABBITMQ_PORT: "5672"
  APP_RABBITMQ_USER: "guest"
  APP_RABBITMQ_PASS: "5Cd5VXoj3RfBMngj"

  # MQTT
  APP_MQTT_HOST: "hive-mq-mqtt.b2b-network"
  APP_MQTT_PORT: "1885"
  APP_MQTT_USER: "admin"
  APP_MQTT_PASS: "hivemq"

  # Mailing
  APP_SMTP_HOST: mailhog.b2b-network
  APP_SMTP_PORT: "1025"
  APP_SMTP_SECURE: "false"
  APP_SMTP_USER: ""
  APP_SMTP_PASSWORD: ""
```

List of used resources for the applications is the following:
* Deployment
* Service
* Ingress
* PodDisruptionBudget
* HorizontalPodAutoscaler


## Kubernetes worker nodes

AWS Autoscaling Groups are used for the management of Kubernetes worker nodes.
Primarily ASGs are managed by `cluster-autoscaler` component which checks available resources in cluster and makes a decision about scaling based on that.

Cluster autoscaler uses the following conditions for cluster scaling:

* If required resources for all Pods are higher than cluster capacity - create new node.
* If there is node which is underused(usage is below 50%) - check if it is possible to remove the node. If all workloads from node can fit cluster capacity without node - mark node as candidate for removal. After nodes is underused for 10 minutes - remove node.

Cluster scaling does not require **any** manual operations. ASGs should net be manually edited.