#!/bin/bash
set -e
set -u
name=storm
version=0.10.0
description="Storm is a distributed realtime computation system. Similar to how Hadoop provides a set of general primitives
for doing batch processing, Storm provides a set of general primitives for doing realtime computation. Storm is simple, can
be used with any programming language, is used by many companies, and is a lot of fun to use!"
url="http://storm.apache.org/"
arch="all"
section="misc"
package_version="~3"
src_package="apache-storm-${version}.zip"
download_url="http://mirror.symnds.com/software/Apache/storm/apache-storm-0.10.0/apache-storm-0.10.0.zip"
origdir="$(pwd)"
storm_root_dir=/usr/lib/storm
#use old debian init.d scripts or ubuntu upstart
dist="debian"

# add e.g. to ~/.bash_profile 'export MAINTAINER="your@email.com"'
# if variable not set, use default value
if [[ -z "$MAINTAINER" ]]; then
  MAINTAINER="${USER}@localhost"
fi

#_ MAIN _#
rm -rf ${name}*.deb
if [[ ! -f "${src_package}" ]]; then
  curl -LO ${download_url}
fi
mkdir -p tmp && pushd tmp
rm -rf storm
mkdir -p storm
cd storm
mkdir -p build${storm_root_dir}
mkdir -p build/etc/default
mkdir -p build/etc/storm
if [ $dist == "debian" ]; then
  mkdir -p build/etc/init.d
else
  mkdir -p build/etc/init
fi
mkdir -p build/var/log/storm
mkdir -p build/var/lib/storm

unzip ${origdir}/${src_package}
rm -rf apache-storm-${version}/logs
rm -rf apache-storm-${version}/log4j
rm -rf apache-storm-${version}/conf
cp -R apache-storm-${version}/* build${storm_root_dir}

cd build
cp ${origdir}/storm ${origdir}/storm-nimbus ${origdir}/storm-supervisor ${origdir}/storm-ui ${origdir}/storm-drpc etc/default
cp ${origdir}/storm.yaml etc/storm
cp ${origdir}/storm.log.properties etc/storm
if [ $dist == "debian" ]; then
  cp ${origdir}/init.d/storm-nimbus ${origdir}/init.d/storm-logviewer ${origdir}/init.d/storm-supervisor ${origdir}/init.d/storm-ui ${origdir}/init.d/storm-drpc etc/init.d
else
  cp ${origdir}/storm-nimbus.conf ${origdir}/storm-logviewer.conf ${origdir}/storm-supervisor.conf ${origdir}/storm-ui.conf ${origdir}/storm-drpc.conf etc/init
fi 


#_ MAKE DEBIAN _#
fpm -t deb \
    -n ${name} \
    -v ${version}${package_version} \
    --description "${description}" \
    --url="{$url}" \
    -a ${arch} \
    --category ${section} \
    --vendor "" \
    -m "$MAINTAINER" \
    --before-install ${origdir}/before_install.sh \
    --after-install ${origdir}/after_install.sh \
    --after-remove ${origdir}/after_remove.sh \
    --prefix=/ \
    -d "libzmq3 >= 3.1.3" -d "libjzmq >= 2.1.0" -d "unzip" \
    -s dir \
    -- .
mv storm*.deb ${origdir}
popd
