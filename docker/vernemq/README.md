# How to create and upload new image to ECR

1. Login ECR

For AWS CLI version 1

Get token
```
aws ecr get-login --region ap-northeast-1 --no-include-email
```
then paste command
```
docker login -u AWS -p {{ token }} https://017989227367.dkr.ecr.ap-northeast-1.amazonaws.com
```

For AWS CLI version2:

```
aws ecr get-login-password --profile ls --region ap-northeast-1 | docker login --username AWS --password-stdin 017989227367.dkr.ecr.ap-northeast-1.amazonaws.com
```

2. Build and upload
```
make build-upload
```