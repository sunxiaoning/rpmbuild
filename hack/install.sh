#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

USE_DOCKER=${USE_DOCKER:-"0"}

BUILD_USER_HOME=${BUILD_USER_HOME:-"/root"}
ARCH=${ARCH:-"x86_64"}

APP_NAME=nginx
APP_VERSION=${APP_VERSION:-"1.26.1"}
RELEASE=${RELEASE-"2"}
DIST=${DIST:-"el8"}

install-repo() {
  echo "Install RPM to repo..."
  TOPDIR=${BUILD_USER_HOME}/rpmbuild/${APP_NAME}/${APP_VERSION}
  RPM_NAME=${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.${ARCH}.rpm
  LOCAL_REPO_PATH=/opt/rpmrepo/${APP_NAME}/${APP_VERSION}

	mkdir -p ${LOCAL_REPO_PATH}
	install -D -m 644 ${TOPDIR}/RPMS/${ARCH}/${RPM_NAME} ${LOCAL_REPO_PATH}/${RPM_NAME}
	createrepo ${LOCAL_REPO_PATH}
}

install-reponginx() {
  echo "Install nginx RPM to repo..."

  echo "Install nginx 1.26.1 rpm ..."
  APP_NAME=nginx
  APP_VERSION=1.26.1
  RELEASE=2
  DIST=el8

  # install-repo
  sleep 1

  echo "Install nginx 1.24.0 rpm ..."
  APP_VERSION=1.24.0
  RELEASE=1
  DIST=el8

  # install-repo
  sleep 1

  echo "Install nginx 1.22.1 rpm ..."
  APP_VERSION=1.22.1
  RELEASE=1
  DIST=el8

  install-repo
}

install-repoall() {
  echo "Install all RPM to repo..."
  install-reponginx
}

install-rpm() {
  echo "Install RPM from repo..."
  LOCAL_REPO_PATH=/opt/rpmrepo/${APP_NAME}/${APP_VERSION}
  RPM_NAME=${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.${ARCH}.rpm

	rpm -ivh ${LOCAL_REPO_PATH}/${RPM_NAME}
}

install-rpmnginx() {
  echo "Install nginx RPM from repo..."

  APP_NAME=nginx
  APP_VERSION=1.26.1
  RELEASE=2
  DIST=el8

  install-rpm
}

install-rpmall() {
  echo "Install all RPM from repo..."

  install-rpmnginx
}

uninstall() {
  echo "Uninstall RPM"
	rpm -evh ${APP_NAME}-${APP_VERSION}
}

main() {
  if [[ "1" == "${USE_DOCKER}" ]]; then
    echo "Begin to build with docker."
    case "${1-}" in
    repo)
      install-repo-docker
      ;;
    reponginx)
      install-reponginx-docker
      ;;
    repoall)
      install-repoall-docker
      ;;
    rpm)
      install-rpm-docker
      ;;
    rpmnginx)
      install-rpmnginx-docker
      ;;
    rpmall)
      install-rpmall-docker
      ;;
    *)
      install-rpmall-docker
      ;;
    esac
  else
    echo "Begin to build in the local environment."
    case "${1-}" in
    repo)
      install-repo
      ;;
    reponginx)
      install-reponginx
      ;;
    repoall)
      install-repoall
      ;;
    rpm)
      install-rpm
      ;;
    rpmnginx)
      install-rpmnginx
      ;;
    rpmall)
      install-rpmall
      ;;
    *)
      install-rpmall
      ;;
    esac
  fi
}

main "$@"
