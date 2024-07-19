#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

USE_DOCKER=${USE_DOCKER:-"0"}

OS_NAME=${OS_NAME:-"centos"}
OS_VERSION=${OS_VERSION:-"8"}

BUILD_USER_HOME=${BUILD_USER_HOME:-"/root"}


APP_NAME=nginx
APP_VERSION=${APP_VERSION:-"1.26.1"}
RELEASE=${RELEASE-"2"}
DIST=${DIST:-"el8"}
TOPDIR=${BUILD_USER_HOME}/rpmbuild/${APP_NAME}/${APP_VERSION}
SRPM_NAME=${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.src.rpm 

declare -A srpm_url

srpm_url["nginx"]="http://nginx.org/packages/${OS_NAME}/${OS_VERSION}/SRPMS/${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.ngx.src.rpm"

prepare() {
  echo "Prepare workspace..."
  mkdir -p ${TOPDIR}/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
  if [ ! -f "${TOPDIR}/SRPMS/${SRPM_NAME}" ]; then
    echo "curl url: http://nginx.org/packages/${OS_NAME}/${OS_VERSION}/SRPMS/${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.ngx.src.rpm"
    curl -Lo "${TOPDIR}/SRPMS/${SRPM_NAME}" "${srpm_url[${APP_NAME}]}"
    rpm --define "_topdir $TOPDIR"  -Uvh ${TOPDIR}/SRPMS/${SRPM_NAME}
  fi
}

build-srpm() {
  echo "Build SRPM..."
  rpmbuild --define "_topdir $TOPDIR"  -bs ${TOPDIR}/SPECS/${APP_NAME}.spec
}

build-rpm() {
  echo "Build RPM..."
  rpmbuild --define "_topdir $TOPDIR" --rebuild ${TOPDIR}/SRPMS/${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.src.rpm
}

rebuild-rpm() {
  echo "Rebuild RPM..."
  rpmbuild --define "_topdir $TOPDIR" -bb ${TOPDIR}/SPECS/${APP_NAME}.spec
}

main() {
  if [[ "1" == "${USE_DOCKER}" ]]; then
    echo "Begin to build with docker."
    case "${1-}" in
    prep)
      prepare-docker
      ;;
    srpm)
      build-srpm-docker
      ;;
    rpm)
      build-rpm-docker
      ;;
    rerpm)
      rebuild-rpm-docker
      ;;
    repo)
      install-repo-docker
      ;;
    # install)
    #   install-docker
    #   ;;
    # uninstall)
    #   uninstall-docker
    #   ;;
    *)
    install-docker
    ;;
    esac
  else
    echo "Begin to build in the local environment."
    case "${1-}" in
    prep)
      prepare
      ;;
    srpm)
      build-srpm
      ;;
    rpm)
      build-rpm
      ;;
    rerpm)
      rebuild-rpm
      ;;
    repo)
      install-repo
      ;;
    install)
      install
      ;;
    # uninstall)
    #   uninstall
    #   ;;
    *)
      install
      ;;
    esac
  fi
}

main "$@"
