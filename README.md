# rpmbuild
build rpm package

1. prepare workspace on server host
    
    `APP_NAME=app_name APP_VERSION=app_version RELEASE=release make prepare`
2. download rpmbuild tmpl to client host.

3.  edit SOURCES && SPECS contents on client host, then apply all to server host.
5. on server host

    `APP_NAME=app_name APP_VERSION=app_version RELEASE=release make install`
