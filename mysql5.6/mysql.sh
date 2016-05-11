#!/bin/bash

#mysql编译环境依赖包
yum install vim-enhanced telnet net-tools cmake ncurses ncurses-devel gcc gcc-c++


#解决ulimit -n(65535)
/bin/grep "65535" /etc/security/limits.conf
if [ $? -eq 1 ];then
cat >>/etc/security/limits.conf <<EOF
* soft nofile 65535
* hard nofile 65535
EOF
fi

#mysql running user --->mysql
id mysql >/dev/null
if [ $? -eq 0 ];then
echo "www user is exist"
else
useradd -r -M -s /sbin/nologin mysql
fi
sleep 5

#mysql need directory
mkdir /data/logs/ -p
mkdir /data/mysql/ -p
chown mysql:mysql /data/mysql/ -R

#mysql install --->mysql源码包下载地址:http://ftp.kaist.ac.kr/mysql/Downloads/MySQL-5.6/
#yum install mariadb mariadb-devel mariadb-server -y
tar xf /opt/mysql-5.6.27.tar.gz -C /opt
cd /opt/mysql-5.6.27/
rm -rf CMakeCache.txt
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/data/mysql -DDEFAULT_CHARSET=utf8 -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_DEBUG=0 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_USER=mysql -DMYSQL_USER=mysql
make && make install
chown mysql:mysql /usr/local/mysql/ -R
mv /etc/my.cnf{,.bak}
cd /usr/local/mysql/
cp support-files/my-default.cnf /etc/my.cnf
/usr/local/mysql/scripts/mysql_install_db --user=mysql --datadir=/data/mysql/ --basedir=/usr/local/mysql/
#/usr/local/mysql//bin/mysqladmin -u root password 'new-password'
cp support-files/mysql.server /etc/init.d/mysqld
chmod 755 /etc/init.d/mysqld
echo "export PATH=/usr/local/mysql/bin:$PATH" >>/root/.bashrc
source /root/.bashrc
/etc/init.d/mysqld start
#mysql_secure_installation
#/etc/init.d/mysqld restart
:<<!
更改数据库data目录步骤
1./usr/local/mysql/scripts/mysql_install_db --user=mysql --datadir=/data/mysql/ --basedir=/usr/local/mysql/
2.修改my.cnf里面的data目录
3.chown mysql:mysql /data/mysql -R
4./etc/init.d/mysqld start
5.mysql_secure_installation
!
