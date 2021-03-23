# Kubernetes cluster resources overview

## Software needed

* [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) 
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) version 1.13
* [Helm](https://helm.sh/docs/using_helm/#installing-the-helm-client) version 2.13.1

## General notes

All cluster resources which require access through the Web interface are exposed via Ingress resources.

If software component do not have built-in authentication module `Basic auth` was applied to secure access. Basic auth configuration can be found at `/kube/additional/internal-resources-cm.yml`

## Software installed

### Cert Manager

Chart: `/kube/charts/cert-manager`

Config: `/kube/configs/cert-manager`

Description: Cert manager is Certificate issuer which uses different back-ends for management of SSL certificates. Current setup uses LetsEncrypt issuer and provides certificates for all resources exposed via Ingress.

Default annotations for Ingress which are required for Cert-manager integration are:

```yaml
annotations:
  kubernetes.io/ingress.class: nginx
  kubernetes.io/tls-acme: "true"
```



### Cluster autoscaler

Chart: `/kube/charts/cluster-autoscaler`

Config: `/kube/configs/cluster-autoscaler`

Description: CA is software which is used for automatic scaling of cluster. This component was described in `kubernetes-resources-overview` doc.

### Fluentd

Chart: `/kube/charts/fluentd-cloudwatch`

Config: `/kube/configs/fluentd-cloudwatch`

Description: This component is used to push all applications logs from the Kubernetes cluster into the Cloudwatch Logs.

It utilizes adds Kubernetes pods metadata to the every log event and pushes event to the Cloudwatch Logs.

### HiveMQ

Chart: `/kube/charts/hive-mq`

Config: `/kube/configs/hive-mq`

Description: HiveMQ is MQTT message broker. Existing configuration exposes MQTT via LoadBalancer.

WebUI is only accessible from inside cluster by forwarding port to the service:

```bash
kubectl --namespace=configuration port-forward svc/hive-mq-web 8084:8080
```

After this it will be available on `localhost:8084`

### jenkins

Chart: `/kube/charts/jenkins`

Config: `/kube/configs/jenkins`

WebUI: [https://jenkins.2c98ao.live-smart.io](https://jenkins.2c98ao.live-smart.io/)

Auth: built-in auth.

Description: Jenkins CI/CD server is using kubernetes plugin for running pipelines in the pods. Pipeline configuration for the Jenkins is located in the main source repository under `/ci/jeknins/Jenkinsfile`.  Pipeline configuration is written in `pipeline` code style.

Jenkins pipeline consists of the following steps:

* SCM checkout - Stage which pulls code from repository
* NPM dependencies - Stage which install required NodeJS dependencies
* Lint - Stage which runs ESLint rules agains code and reports errors if the occur.
* Docker Build - Stage which utilizes Docker in Docker mechanism and builds Docker image which is stored in ECR.
* Deploy - Deploys two helm charts(located in source repository `./ci/helm`). 
Separate charts are deploying Web and Workers application separately from each other. 

### Kube OPS view

Chart: `/kube/charts/kube-ops-view`

Config: `/kube/configs/kube-ops-view`

WebUI: [https://kubeops-2c98ao.dev.live-smart.io](https://kubeops-2c98ao.dev.live-smart.io/)

Auth: basic auth

Description: this service is only used for quick validation of cluster workloads state. It allows check if application is running, which nodes are utilized for the current needs.

### Mailhog

Chart: `/kube/charts/mailhog`

Config: `/kube/configs/mailhog`

WebUI: [http://mailhog-2c98ao.dev.live-smart.io](http://mailhog-2c98ao.dev.live-smart.io/)

Auth: basic auth

Description: this service is used for SMTP integration testing. It provides ability to push emails to service via smtp and displays all captured emails via WebUI.

### Metrics server

Chart: `/kube/charts/metrics-server`

Config: `/kube/configs/metrics-server`

Description: core component for the workloads scaling. Provides an API to get Workloads resources usage for the scaling.

### Nginx Ingress

Chart: `/kube/charts/nginx-ingress`

Config: `/kube/configs/nginx-ingress`

Description: core component for web resources exposing from cluster. It registers AWS LoadBalancer which will be used to communicate with. Nginx Ingress controller acts as a proxy between external LoadBalancer and cluster internally running workloads.

### Prometheus

Chart: `/kube/charts/prometheus-operator`

Config: `/kube/configs/prometheus-operator`

Description: Component for cluster resources monitoring. Provides set of APIs which allows to set up metrics gathering in the central Prometheus server.

Deploys the following componentes:

* Prometheus server - application core
* Prometheus web UI
* Grafana 
* Alertmanager

#### Prometheus Web

URL: [https://prometheus-2c98ao.dev.live-smart.io](https://prometheus-2c98ao.dev.live-smart.io/)

Auth: basic auth

Description: prometheus server Web UI which is used for quick debugging of monitoring process.

### Alertmanager

URL: https://am-2c98ao.dev.live-smart.io/

Auth: basic auth

Description: Service which is utilizing Prometheus metrics and sends notifications if any error occurred.
Configured application alerts:

* LsMiddlewareUnhandledExceptionsHigh - referring to the number of errors thrown by application.
* LsMiddlewareUnhandledRejectionsHigh  - referring to the number of errors thrown by application.
* LsMiddlewareRMQMessagesHigh - referring to the number of messages which are not handled in the RabbitMQ queues.
* LsMiddlewareRequestsLow  - referring to the state when no HTTP calls was made to an application which is only possible if application is completely unavailable.

### Grafana

URL: [https://grafana-2c98ao.dev.live-smart.io](https://grafana-2c98ao.dev.live-smart.io/)

Auth: internal auth. credentials stored in config.

Description: Service which is responsible for the visual representation of metrics from prometheus.

Provides the following important dashboards:

* https://grafana-2c98ao.dev.live-smart.io/d/t8FywqKWz/application-basic-metrics

  This dashboard provides an overview on application state. It shows number of running instances, errors and generic HTTP requests statistics.

* https://grafana-2c98ao.dev.live-smart.io/d/lsWg_qFWk/application-advanced-metrics

  This dashboard provides more details information about applications running in cluster and primarily addressed to developers of other technicians to quickly identify and resolve issues.

Other useful dashboards:

* https://grafana-2c98ao.dev.live-smart.io/d/a87fb0d919ec0ea5f6543124e16c42a5/kubernetes-compute-resources-namespace-workloads

  This dashboard allows to see resources usage by each workload running in cluster. This is useful for proper cluster resources management.

* https://grafana-2c98ao.dev.live-smart.io/d/efa86fd1d0c121a26444b636a3f509a8/kubernetes-compute-resources-cluster

  This dashboard provides all cluster resources overview and is useful for planning of resources required for cluster capacity.

### RabbitMQ

Chart: `/kube/charts/rabbitmq-ha`

Config: `/kube/configs/rabbitmq-ha`

Description: Component for deployment of highly available RabbitMQ cluster. Now deploys cluster consisting of three nodes which are used by main application.

## LS Middleware applicatoin

### Overview

For deployment the following Kubernetes components are used:
* Deployment
* Service
* HorizontalPodAutoscaler
* Ingress
* PodDisruptionBudget

These resources are creating set of docker containers running over different worker nodes.
External access to the Web application is granted by utilizing the following chain of resources:
```
Ingress -> Service -> Pods
```
So all users traffic goes through Nginx Ingress and comes to pods.
Traffic to the Ingress is handled by using AWS LoadBalancer.
 
### Applications resources and scaling

Applications resources usage is based on Kubernetes deployment resources limiting.

Current applications resources limits are the following:
* Web application
```
   limits:
     cpu: 1
     memory: 1024Mi
   requests:
     cpu: 500m
     memory: 512Mi
```

* Workers application
```
  limits:
    cpu: 1
    memory: 2Gi
  requests:
    cpu: 750m
    memory: 2Gi
```

These values were calculated by performance loading application and monitoring application resources utilization.

For the application scaling HorizontalPodsAutoscaler keeps track on applications resources usage and if resources requested by application are utilized over 60% - spawns new instance of application.
Downscale of resources is applied when resources usage is above 60% for more than 5 minutes.