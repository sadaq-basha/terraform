build:
	docker build -f ./Dockerfile -t ls-server/mqtt-service

build-upload:
	docker build -f ./Dockerfile -t ls-server/mqtt-service .
	docker tag ls-server/mqtt-service:latest 017989227367.dkr.ecr.ap-northeast-1.amazonaws.com/ls-server/mqtt-service:latest
	docker push 017989227367.dkr.ecr.ap-northeast-1.amazonaws.com/ls-server/mqtt-service:latest

login:
	aws ecr get-login --region us-east-1 --profile ls --no-include-email