#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE}")")

. ${SCRIPT_DIR}/env.sh

install-repo() {
  echo "Install RPM to repo..."
  TOPDIR="${BUILD_USER_HOME}/rpmbuild/${APP_NAME}/${APP_VERSION}"
  RPM_NAME="${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.${ARCH}.rpm"
  LOCAL_REPO_PATH="/opt/rpmrepo/${APP_NAME}/${APP_VERSION}"

  mkdir -p "${LOCAL_REPO_PATH}"
  install -D -m 644 "${TOPDIR}/RPMS/${ARCH}/${RPM_NAME}" "${LOCAL_REPO_PATH}/${RPM_NAME}"
  createrepo "${LOCAL_REPO_PATH}"
}

install-reponginx() {
  echo "Install nginx RPM to repo..."

  echo "Install nginx ${LATEST_NGINX_VERSION} rpm ..."
  APP_NAME="${NGINX_APP_NAME}"
  APP_VERSION="${LATEST_NGINX_VERSION}"
  RELEASE="${LATEST_NGINX_RELEASE}"

  install-repo

  echo "Install nginx 1.24.0 rpm ..."
  APP_VERSION="1.24.0"
  RELEASE="1"

  install-repo

  echo "Install nginx 1.22.1 rpm ..."
  APP_VERSION="1.22.1"
  RELEASE="1"

  install-repo
}

install-repoall() {
  echo "Install all RPM to repo..."
  install-reponginx
}

install-rpm() {
  echo "Install RPM from repo..."
  LOCAL_REPO_PATH="/opt/rpmrepo/${APP_NAME}/${APP_VERSION}"
  RPM_NAME="${APP_NAME}-${APP_VERSION}-${RELEASE}.${DIST}.${ARCH}.rpm"

  rpm -ivh "${LOCAL_REPO_PATH}/${RPM_NAME}"
}

install-rpmnginx() {
  echo "Install nginx RPM from repo..."

  APP_NAME="${NGINX_APP_NAME}"
  APP_VERSION="${LATEST_NGINX_VERSION}"
  RELEASE="${LATEST_NGINX_RELEASE}"

  install-rpm
}

install-rpmall() {
  echo "Install all RPM from repo..."

  install-rpmnginx
}

uninstall() {
  echo "Uninstall RPM"
  rpm -evh "${APP_NAME}-${APP_VERSION}"
}

main() {
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
}

main "$@"
