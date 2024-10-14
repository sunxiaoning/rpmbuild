init: 
	yum install rpm-build rpm-devel rpmlint coreutils rpmdevtools gcc make openssl-devel pcre-devel zlib-devel

default: build-rpm

prepare: init
	./hack/build.sh prep

# build the project
build-srpm:
	./hack/build.sh srpm

build-snginx:
	./hack/build.sh snginx

build-sall:
	./hack/build.sh sall

build-rpm: build-srpm
	./hack/build.sh rerpm

build-nginx: build-snginx
	./hack/build.sh renginx

build-all: build-sall
	./hack/build.sh reall

rebuild-rpm: build-srpm
	./hack/build.sh rerpm

rebuild-nginx: build-snginx
	./hack/build.sh renginx

rebuild-all: build-sall
	./hack/build.sh reall

install-repo: build-rpm
	./hack/install.sh repo

install-reponginx: build-nginx
	./hack/install.sh reponginx

install-repoall: build-all
	./hack/install.sh repoall

install-rpm: install-repo
	./hack/install.sh rpm

install-rpmnginx: install-reponginx
	./hack/install.sh rpmnginx

install-rpmall: install-repoall
	./hack/install.sh rpmall

uninstall-rpm:
	./hack/uninstall.sh rpm

uninstall-rpmnginx:
	./hack/uninstall.sh rpmnginx

uninstall-rpmall:
	./hack/uninstall.sh rpmall