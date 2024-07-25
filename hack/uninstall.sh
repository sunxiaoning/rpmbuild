#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

USE_DOCKER=${USE_DOCKER:-"0"}

BUILD_USER_HOME=${BUILD_USER_HOME:-"/root"}
ARCH=${ARCH:-"x86_64"}

APP_NAME=nginx

uninstall-rpm() {
  echo "Uninstall RPM"
	rpm -evh ${APP_NAME}
}

uninstall-nginxrpm() {
  echo "Uninstall nginx RPM"
	
  APP_NAME=nginx  
  uninstall-rpm
}

uninstall-allrpm() {
  echo "Uninstall all RPM"
  uninstall-nginxrpm
}


main() {
  if [[ "1" == "${USE_DOCKER}" ]]; then
    echo "Begin to build with docker."
    case "${1-}" in
    rpm)
      uninstall-rpm-docker
      ;;
    nginxrpm)
      uninstall-nginxrpm-docker
      ;;
    allrpm)
      uninstall-allrpm-docker
      ;;
    *)
      uninstall-allrpm-docker
      ;;
    esac
  else
    echo "Begin to build in the local environment."
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
  fi
}

main "$@"
