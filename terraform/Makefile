plan-all:
	cd shared && terraform plan
	terraform workspace select test && ./terraform-wrapper.sh plan
	terraform workspace select dev && ./terraform-wrapper.sh plan
	terraform workspace select prod && ./terraform-wrapper.sh plan