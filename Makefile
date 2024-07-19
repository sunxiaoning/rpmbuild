init: 
	yum install rpm-build rpm-devel rpmlint coreutils rpmdevtools gcc make openssl-devel pcre-devel zlib-devel

default: build-rpm

prepare:
	./hack/build.sh prep

# build the project
build-srpm:
	./hack/build.sh srpm

build-rpm: build-srpm
	./hack/build.sh rerpm

rebuild-rpm: build-srpm
	./hack/build.sh rerpm

install-repo: build-rpm
	./hack/install.sh repo

install: install-repo
	./hack/install.sh install

uninstall:
	./hack/install.sh uninstall