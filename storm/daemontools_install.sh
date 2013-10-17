#!/usr/bin/env bash
#export JAVA_HOME=${JAVA_HOME:/usr/libexec/java_home}



Usage(){
echo "
Usage:./daemontools_install.sh
"
}

getSource(){
rm -rf install_tmp
mkdir -p install_tmp
cd install_tmp
wget $1 --no-check-certificate
mv * tmp.tar.gz
tar -zxvf tmp.tar.gz
rm -rf tmp.tar.gz
mv * ../$2
cd ../
rm -rf install_tmp
}

mkdir -p /tmp/daemontools_install_tmp
cd /tmp/daemontools_install_tmp

daemontools_url=http://cr.yp.to/daemontools/daemontools-0.76.tar.gz
patch_url=http://www.qmail.org/moni.csi.hu/pub/glibc-2.3.1/daemontools-0.76.errno.patch
getSource ${daemontools_url} admin
cd admin/daemontools-0.76
cd src
wget ${patch_url} --no-check-certificate
patch < daemontools-0.76.errno.patch
cd ..
./package/install

cd /tmp
rm -rf /tmp/daemontools_install_tmp

