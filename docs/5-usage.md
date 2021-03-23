## General useful commands
```bash
# List all running pods in application namespace
kubectl --namespace=application get po

# Same for the configuration namespace
kubectl --namespace=configuration get po

# To get scaling components status
kubectl --namespace=application get hpa
# Output example
NAME                                   REFERENCE                                         TARGETS           MINPODS   MAXPODS   REPLICAS   AGE
ls-dev-ls-middleware-web               Deployment/ls-dev-ls-middleware-web               26%/70%, 1%/70%   5         30        5          5d12h
ls-dev-workers-ls-middleware-workers   Deployment/ls-dev-workers-ls-middleware-workers   46%/70%, 0%/70%   5         20        5          10h

# See Ingress resources used
kubectl --namespace=application get ing
# Output example
ls-dev-ls-middleware-web   dev.lsdev.r-styleserv.com             80, 443   5d12h

# To get application logs directly from the Kubernetes:
kubectl get po
# Output
ls-dev-ls-middleware-web-7488c9955-6xmsd                1/1     Running   0          5h46m
ls-dev-ls-middleware-web-7488c9955-hhv5r                1/1     Running   0          5h29m

# To follow the logs of Pod
kubectl logs -f ls-dev-ls-middleware-web-7488c9955-6xmsd
```



## Logs 

Logs are available in the Cloudwatch Logs and directly from the Kubernetes cluster.

Stream naming convention for the Cloudwatch is the following: `var.log.containers.{pod-name}` where pod name contains `{deployment replica set name}-{unique pod identifier}`

To search for the specific keywork it is possible to use Full Text Search(FTS). To do that "Search log group" button on the top of the streams list screen is available( https://ap-northeast-1.console.aws.amazon.com/cloudwatch/home?region=ap-northeast-1#logStream:group=/aws/eks/dev/pods;streamFilter=typeLogStreamPrefix )

Another options which is more applicable for debugging is using Kubernetes access and `kubectl` tool.

To get logs via `kubectl` the following commands should be used:

```bash
# To get application logs directly from the Kubernetes:
kubectl get po
# Output
ls-dev-ls-middleware-web-7488c9955-6xmsd                1/1     Running   0          5h46m
ls-dev-ls-middleware-web-7488c9955-hhv5r                1/1     Running   0          5h29m

# To follow the logs of Pod
kubectl logs -f ls-dev-ls-middleware-web-7488c9955-6xmsd
```

[Stern ](https://github.com/wercker/stern) tool can be used to get output from multiple pods at the same time which is very useful for debugging.

Stern command example:

```bash
# Returns logs from all pods which contains ls-middleware-web in pod name
stern ls-middleware-web
```

