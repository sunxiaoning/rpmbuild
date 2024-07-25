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

declare -A srpm_url

prepare() { 
  echo "Prepare workspace..."
  TOPDIR=${BUILD_USER_HOME}/rpmbuild/${APP_NAME}/${APP_VERSION}
  SRPM_NAME=${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.src.rpm
  srpm_url["nginx"]="http://nginx.org/packages/${OS_NAME}/${OS_VERSION}/SRPMS/${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.ngx.src.rpm"


  mkdir -p ${TOPDIR}/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
  if [ ! -f "${TOPDIR}/SRPMS/${SRPM_NAME}" ]; then
    echo "curl url: http://nginx.org/packages/${OS_NAME}/${OS_VERSION}/SRPMS/${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.ngx.src.rpm"
    curl -Lo "${TOPDIR}/SRPMS/${SRPM_NAME}" "${srpm_url[${APP_NAME}]}"
    rpm --define "_topdir $TOPDIR"  -Uvh ${TOPDIR}/SRPMS/${SRPM_NAME}
  fi
}

build-srpm() {
  echo "Build SRPM..."
  TOPDIR=${BUILD_USER_HOME}/rpmbuild/${APP_NAME}/${APP_VERSION}

  rpmbuild --define "_topdir $TOPDIR"  -bs ${TOPDIR}/SPECS/${APP_NAME}.spec
}

build-snginx() {
  echo "Build nginx SRPM..."
  APP_NAME=nginx
  APP_VERSION=1.26.1
  build-srpm
  
  APP_VERSION=1.24.0
  build-srpm

  APP_VERSION=1.22.1
  build-srpm
}

build-sall() {
  echo "Build all SRPM..."
  build-snginx
}


build-rpm() {
  echo "Build RPM..."
  TOPDIR=${BUILD_USER_HOME}/rpmbuild/${APP_NAME}/${APP_VERSION}

  rpmbuild --define "_topdir $TOPDIR" --rebuild ${TOPDIR}/SRPMS/${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.src.rpm
}

build-nginx() {
  echo "Build nginx RPM..."

  echo "Build nginx 1.26.1 RPM..."
  APP_NAME=nginx
  APP_VERSION=1.26.1
  RELEASE=2
  DIST=el8
  build-rpm
  sleep 1

  echo "Build nginx 1.24.0 RPM..."
  APP_VERSION=1.24.0
  RELEASE=1
  DIST=el8
  build-rpm
  sleep 1

  echo "Build nginx 1.22.1 RPM..."
  APP_VERSION=1.22.1
  RELEASE=1
  DIST=el8
  build-rpm
}

build-all() {
  echo "Build all RPM..."
  build-nginx
}

rebuild-rpm() {
  echo "Rebuild RPM..."
  TOPDIR=${BUILD_USER_HOME}/rpmbuild/${APP_NAME}/${APP_VERSION}

  rpmbuild --define "_topdir $TOPDIR" -bb ${TOPDIR}/SPECS/${APP_NAME}.spec
}

rebuild-nginx() {
  echo "Rebuild nginx RPM..."
    
  echo "Rebuild nginx 1.26.1 RPM..."
  APP_NAME=nginx
  APP_VERSION=1.26.1
  rebuild-rpm
  sleep 1
  
  echo "Rebuild nginx 1.24.0 RPM..."
  APP_VERSION=1.24.0
  rebuild-rpm
  sleep 1

  echo "ReBuild nginx 1.22.1 RPM..."
  APP_VERSION=1.22.1
  rebuild-rpm
}

rebuild-all() {
  echo "Rebuild all RPM..."
  rebuild-nginx
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
    snginx)
      build-snginx-docker
      ;;
    sall)
      build-sall-docker
      ;;
    rpm)
      build-rpm-docker
      ;;
    nginx)
      build-nginx-docker
      ;;
    all)
      build-all-docker
      ;;
    rerpm)
      rebuild-rpm-docker
      ;;
    renginx)
      rebuild-nginx-docker
      ;;
    reall)
      rebuild-all-docker
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
    snginx)
      build-snginx
      ;;
    sall)
      build-sall
      ;;
    rpm)
      build-rpm
      ;;
    nginx)
      build-nginx
      ;;
    all)
      build-all
      ;;
    rerpm)
      rebuild-rpm
      ;;
    renginx)
      rebuild-nginx
      ;;
    reall)
      rebuild-all
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
