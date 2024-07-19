# nginx-rpmbuild
1. on server host
APP_NAME=nginx APP_VERSION=1.26.1 RELEASE=2 make prepare
2. on client host
edit SOURCES && SPECS contents
3. on server host
APP_NAME=nginx APP_VERSION=1.26.1 RELEASE=2 make install
