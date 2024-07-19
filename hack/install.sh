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
TOPDIR=${BUILD_USER_HOME}/rpmbuild/${APP_NAME}/${APP_VERSION}
RPM_NAME=${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.${ARCH}.rpm 


LOCAL_REPO_PATH=/opt/repo/${APP_NAME}/${APP_VERSION}

install-repo() {
  echo "Install RPM to repo..."
	mkdir -p ${LOCAL_REPO_PATH}
	cp ${TOPDIR}/RPMS/${ARCH}/${RPM_NAME} ${LOCAL_REPO_PATH}
	createrepo ${LOCAL_REPO_PATH}
}

install() {
  echo "Install RPM from repo..."
	rpm -ivh ${LOCAL_REPO_PATH}/${RPM_NAME}
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
    install)
      install-docker
      ;;
    uninstall)
      uninstall-docker
      ;;
    *)
      install-docker
      ;;
    esac
  else
    echo "Begin to build in the local environment."
    case "${1-}" in
    repo)
      install-repo
      ;;
    install)
      install
      ;;
    uninstall)
      uninstall
      ;;
    *)
      install
      ;;
    esac
  fi
}

main "$@"
