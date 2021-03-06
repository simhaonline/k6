.PHONY: reset
reset:
	vagrant destroy && vagrant up

.PHONY: kdk_deps
kdk_deps:
	sudo apt-get update && sudo apt-get -y install psmisc # for killall
	helm init --client-only
	helm plugin install https://github.com/databus23/helm-diff
	helm plugin install https://github.com/rimusz/helm-tiller

.PHONY: osx_deps
osx_deps:
	brew install helmfile kubernetes-helm
	helm plugin install https://github.com/databus23/helm-diff
	helm plugin install https://github.com/rimusz/helm-tiller
	vagrant plugin install vagrant-cachier
	vagrant plugin install vagrant-proxyconf

.PHONY: kubeconfig
kubeconfig:
	mkdir -p ~/.kube
	cp admin.conf ~/.kube/config
	sed -i -e 's@server: https://.*:6443@server: https://localhost:6443@g' ~/.kube/config

.PHONY: helmfile
helmfile:
	killall tiller || true
	helm tiller start-ci
	. .envrc && helmfile apply

storage:
	@# Install MaZderMind/hostpath-provisioner
	@#   ref: https://github.com/MaZderMind/hostpath-provisioner
	kubectl apply -f https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/rbac.yaml
	kubectl apply -f https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/deployment.yaml
	kubectl apply -f https://raw.githubusercontent.com/MaZderMind/hostpath-provisioner/master/manifests/storageclass.yaml
