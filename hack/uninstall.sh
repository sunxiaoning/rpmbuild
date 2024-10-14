#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE}")")

. ${SCRIPT_DIR}/env.sh

uninstall-rpm() {
  echo "Uninstall RPM"
  rpm -evh ${APP_NAME}
}

uninstall-nginxrpm() {
  echo "Uninstall nginx RPM"

  APP_NAME="${NGINX_APP_NAME}"
  uninstall-rpm
}

uninstall-allrpm() {
  echo "Uninstall all RPM"
  uninstall-nginxrpm
}

main() {
  case "${1-}" in
  rpm)
    uninstall-rpm
    ;;
  nginxrpm)
    uninstall-nginxrpm
    ;;
  allrpm)
    uninstall-allrpm
    ;;
  *)
    uninstall-allrpm
    ;;
  esac
}

main "$@"
