fmt:
	terraform fmt -recursive

check-fmt:
	terraform fmt -recursive -check

validate-dev:
	terraform -chdir=envs/dev init -backend=false
	terraform -chdir=envs/dev validate

validate-staging:
	terraform -chdir=envs/staging init -backend=false
	terraform -chdir=envs/staging validate

validate-prod:
	terraform -chdir=envs/prod init -backend=false
	terraform -chdir=envs/prod validate

validate-all: validate-dev validate-staging validate-prod