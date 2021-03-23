# Cluster setup steps

## Terraform

### Pre-requirements

Software needed:
* terraform v0.12.6
* aws cli with profile named "ls" or change profile name in appropriate vars file

Setup steps:
* terraform workspace <= select workspace which you will run

* terraform init


For the terraform infrastructure configuration it is needed to tweak 
variables values(if defaults do not match the requirements for the setup) 
and run `terraform apply -var-file {your-var-file-name}`

There are two vars file in repo for dev/prod environments:
* vars-ls.tfvars - dev environment
* vars-ls-prod.tfvars - production environment

Before applying changes terraform will list all the changes which will be made.
Another way to get terraform plan is to use `terraform plan -var-file {your-var-file-name}`.

After resources will be created and configured terraform will create artifacts dir with three files:
* config-map-aws-auth_{cluster_name}.yaml - AWS authentication configuration
* external-resources-cm.yml - Kubernetes configmap which contains links to all external resources(DBs
* kubeconfig_{cluster_name} - Kubernetes configuration file to communicate with created cluster

From the terraform output you need to get the following values:
* docker_repo_web
* docker_worker_web

These are used for the CI/CD configuration.


## Kubernetes configuration

### AWS authentication module

In order to get access to EKS cluster it is required to set up `aws-iam-authenticator`.
Documentation can be found [here](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)

### Import kubernetes config

There are multiple ways to set up multi-configuration kubectl access, you can find documentation for this [here](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)

Suggested one for this configuration is to use ENV variable `KUBECONFIG`,
to do this the following command should be executed from the terraform directory:
```
export KUBECONFIG=$(pwd)/artifacts/kubeconfig_{cluster_name}
```

Validate access by using:
```
kubectl get svc

# Should return 
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   12h
```

### Apply pre-created auth configuration

In the `terraform/artifacts` path file named `config-map-aws-auth_{cluster_name}.yaml` will be created.
Apply configuration:
```
kubectl apply -f artifacts/config-map-aws-auth_{cluster_name}.yaml
```

After this step nodes should appear in kubernetes:
```
kubectl get nodes
```

### Kubernetes software configuration

For the software configuration [Helm](https://helm.sh/docs/) package manager is used: 
The following command should be executed to install Helm in cluster and install software components required:
```bash
# Make sure you are in "kube" directory
cd kube

# Install resources which are required before Helm installation
kubectl apply -f additional/pre-install

# The helm version was not specified, Since the tiller is being used. Its mostly helm2. Below are the ionstallation steps:
wget https://get.helm.sh/helm-v2.16.7-linux-amd64.tar.gz
tar -zxvf helm-v2.16.7-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm

# Verify helm installation
helm version
#Client: &version.Version{SemVer:"v2.13.1", GitCommit:"618447cbf203d147601b4b9bd7f8c37a5d39fbb4", #GitTreeState:"clean"}
#Error: could not find tiller


#Below are the steps to install tiller
kubectl -n kube-system create serviceaccount tiller

kubectl create clusterrolebinding tiller \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:tiller
  
helm init --service-account tiller --history-max 200 --stable-repo-url https://charts.helm.sh/stable
kubectl create namespace configuration
kubectl label namespace configuration certmanager.k8s.io/disable-validation=true

# Installs all charts located in charts directory depending on environment
./install.sh [dev|production|test] [namespace]

# Installs chart by it's name
# Chart name should be same as one in `./kube/charts`.
# For example
./install.sh dev b2b-application vernemq
./install.sh test b2b-application vernemq
# Which will be translated to:
# Environment: dev
# Namespace: b2b-application <= Namespaces are defined in `0-namespace.yaml`
# Chart: vernemq


# Now applying configuration which is required for the cluster running
kubectl apply -f additional/
```

### External domain setup

For the external domain setup it is needed to create a CNAME
record pointing to the Ingress LoadBalancer address.

Ingress LoadBalancer address can be found by using:
```
kubectl get svc nginx-ingress-controller
```
Which prints the following:
```
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP                                                                   PORT(S)                      AGE
nginx-ingress-controller   LoadBalancer   172.20.213.135   a208451dcc7db11e99ab00e80795c4d8-235051194.ap-northeast-1.elb.amazonaws.com   80:32338/TCP,443:32738/TCP   3h10m
```
Where `EXTERNAL-IP` is address of LoadBalancer for CNAME record.

CNAME record should be in the following format(example):
```
*.lsdev.r-styleserv.com. 1800   IN      CNAME   a208451dcc7db11e99ab00e80795c4d8-235051194.ap-northeast-1.elb.amazonaws.com.
```

Note: all resources addresses exposed via ingress should point to this domain.
Configuration for the carts is located at the `config/` directory in appropriate subdirectories.


### Prometheus re-install

Since prometheus helm chart leaves CRDs in cluster it is required to remove them manually by using the following commands:
```bash
kubectl delete crd prometheuses.monitoring.coreos.com
kubectl delete crd prometheusrules.monitoring.coreos.com
kubectl delete crd servicemonitors.monitoring.coreos.com
kubectl delete crd podmonitors.monitoring.coreos.com
kubectl delete crd alertmanagers.monitoring.coreos.com
```

### Access configuration

#### Software needed

- [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) 
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) version 1.13
- [Helm](https://helm.sh/docs/using_helm/#installing-the-helm-client) version 2.13.1

#### AWS profile configuration

For the AWS profile configuraion it is required to have `~/.aws/credentials` file with key secret and ID defined for the access.

Access can be validated by using

```bash
aws sts get-caller-identity
```

#### Kubectl configuration

Steps required to set up `kubectl` are describe on the `Import kubernetes config` step of this doc.

#### Helm configuration

In order to configure helm the following command should be used:

```bash
helm init --client-only
```

After thah

```bash
helm ls
```

Should return the list of installed charts.

## Note(Enomoto san)

### VerneMQ cluster

When I tried to recreate a VerneMQ cluster executing `helm delete vernemq && ./install.sh test vernemq`, I noticed some VerneMQ servers failed to join the cluster due to startup order.  
I will explain how to check and fix it.

```
# You can check how many servers joined the cluster using the following command.
kubectl get pods --all-namespaces -o name | grep vernemq | xargs -I {} kubectl exec -i -n configuration {} -- vmq-admin cluster show

# If you found VerneMQ servers failed to join the cluster, you can delete the pods and Kubernetes automatically recreate the pods you deleted.
# After the pods gets recreated, you should check the status of the cluster again.
kubectl delete pods vernemq-3 varenemq-4 -n configuration
```

## Note(Hikaru)

If you face the error
```
Error: release mailhog failed, and has been uninstalled due to atomic being set: Internal error occurred: failed calling webhook "validate.nginx.ingress.kubernetes.io": Post https://ingress-nginx-controller-admission.network.svc:443/networking/v1beta1/ingresses?timeout=10s: no endpoints available for service "ingress-nginx-controller-admission"
```

You should remove ingress-nginx-admission ValidatingWebhookConfiguration
`kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission`