#!/bin/bash
#export JAVA_HOME=${JAVA_HOME:/usr/libexec/java_home}

if [ ! -d "$JAVA_HOME/include" ]; then
    echo "
Looks like you're missing your 'include' directory. If you're using Mac OS X, You'll need to install the Java dev package.

- Navigate to http://goo.gl/D8lI
- Click the Java tab on the right
- Install the appropriate version and try again.
"
    exit -1;
fi


Usage(){
echo "
Usage:./storm_install.sh configDir [code]
- code
  - 0  install zeromq jzmq storm
    - storm_config_dir
  - 1  install zeromq
  - 2  install jzmq
  - 3  install storm
    - storm_config_dir
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

if [ $# -lt 1 ]
then
Usage
exit -1
fi


if [ $1 == '--help' -o $1 == '-h' ]
then
Usage
exit 0
fi

#test the config directory
if [ ! -d $1 ]
then
echo "the 1st parameter must be a readable directory"
exit -1
fi
#end of testing config directory

code=0
if [ $# -gt 1 ]
then
if [ $2 -lt 0 -o $2 -gt 3 ]
then
Usage
exit -1
fi
code=$2
fi


home=`pwd`

conf_dir=$1
#test the config file
for n in storm-conf.yaml parameters.conf storm;do
file=$conf_dir/$n
if [ ! -r $file ]
then
echo "the config file must be a readable file in the directory $conf_dir"
exit -1
fi
#end of testing config file

python_version=`cat $conf_dir/parameters.conf | grep ^python_version | sed 's/^python_version=//g'`
python_url=`cat $conf_dir/parameters.conf | grep ^python_url | sed 's/^python_url=//g'`
install_path=`cat $conf_dir/parameters.conf | grep ^install_path | sed 's/^install_path=//g'`
storm_conf=$conf_dir/storm-conf.yaml
storm_version=`cat $conf_dir/parameters.conf | grep ^storm_version | sed 's/^storm_version=//g'`
storm_url=`cat $conf_dir/parameters.conf | grep ^storm_url | sed 's/^storm_url=//g'`
zeromq_version=`cat $conf_dir/parameters.conf | grep ^zeromq_version | sed 's/^zeromq_version=//g'`
zeromq_url=`cat $conf_dir/parameters.conf | grep ^zeromq_url | sed 's/^zeromq_url=//g'`
jzmq_url=`cat $conf_dir/parameters.conf | grep ^jzmq_url | sed 's/^jzmq_url=//g'`
storm_hostnames=`cat $conf_dir/storm | awk '{printf("%s ",$1)}'`

isHost=0
for n in $storm_hostnames;do
if [ $hostname == $n ]
then
isHost=1
fi
done

if [ $isHost -ne 1 ]
then
exit 0
fi




python2.6 -V
if [ $? -ne 0 ]
then
if [ ! -d Python-$python_version ]
then
getSource $python_url Python-$python_version
fi
cd Python-$python_version
./configure
make
sudo make install
if [ $? -ne 0 ]
then
echo "install python-$python_version fail"
exit -1
fi
cd ../
rm -rf Python-$python_version
fi


yum install gcc*
yum install uuid*
yum install e2fsprogs*
yum install libuuid*
yum install libtool*




#install zeromq
if [ $code -eq 1 -o $code -eq 0 ]
then
if [ ! -d zeromq-$zeromq_version ]
then
getSource $zeromq_url zeromq-$zeromq_version
fi
cd zeromq-$zeromq_version
./configure
make
sudo make install
if [ $? -ne 0 ]
then
echo "error code:1"
exit -1
fi
cd ../
rm -rf zeromq-$zeromq_version
fi
#end of install zeromq


#install jzmq (both native and into local maven cache)
if [ $code -eq 2 -o $code -eq 0 ]
then
if [ ! -d jzmq ]
then
getSource $jzmq_url jzmq
fi
cd jzmq
./autogen.sh
./configure
make
sudo make install
if [ $? -ne 0 ]
then
echo "error code:2"
exit -1
fi
cd ../
rm -rf jzmq
fi
#end of install jzmq

#install storm
if [ $code -eq 3 -o $code -eq 0 ]
then
#test storm source file
if [ ! -r storm-$storm_version.zip ]
then
wget $storm_url --no-check-certificate
fi
#end of test storm source file
unzip storm-$storm_version.zip
rm -rf storm-$storm_version.zip
mkdir -p $install_path/storm_servers
mv storm-$storm_version $install_path/storm_servers
ln -s $install_path/storm_servers/storm-$storm_version $install_path/storm
chown -R admin:admin $install_path/storm_servers/storm-$storm_version $install_path/storm
cd $home
cat > $install_path/storm/conf/storm.yaml << EOF
`cat $storm_config`
EOF
cat >> /etc/profile << EOF
export STORM_HOME=$install_path/storm
export PATH=\$PATH:\$STORM_HOME/bin
EOF
fi
#end of install storm
