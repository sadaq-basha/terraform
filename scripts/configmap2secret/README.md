configmap2secret.py
---

A script to convert ConfigMap into Secret in k8s manifests.

## Set up

```
python3 -m venv ~/.venv/configmap2secret
source ~/.venv/configmap2secret/bin/activate
pip install -r requirements.txt
```

## How to use

### Convert single file

```
source ~/.venv/configmap2secret/bin/activate

python3 configmap2secret.py ../../kube/config/dev/internal-resources-cm.yml > ../../kube/config/dev/internal-resources-cm.yml.after
```

### Convert all ConfigMap under kube/config/dev

```
find ../../kube/config/dev -type f | xargs -I {} grep -l ConfigMap {} | xargs -I {} bash -c "python3 configmap2secret.py {} > {}.after"
```