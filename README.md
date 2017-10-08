## HDP-1-host-config

> Configuration
- 4 VMs on google compute Engine (3 VM for Hadoop Cluster and 1 VM for data backup and micro services)
- OS: CentOS 7
- RAM: 15 Go
- CPU: 4
- Boot disk: 200Go
- Attached disk: 2000G

> Cluster model

![MetaStore remote database](https://github.com/gamboabdoulraoufou/hdp-1-host-config/blob/master/img/archi_v2.png)

  
> Log as root on all VM and change root password `_All nodes_`  
```sh 
# log as root
sudo su - root

# change root password
passwd # set password
``` 


> Update repo and install some packages `_All nodes_`  
```sh  
# update
yum -y update

# install other packages
yum -y install openssh-server 
yum -y install openssh-clients
yum -y install curl 
yum -y install wget 
yum -y install tar 
yum -y install unzip 
yum -y install telnet 
yum -y install telnet-server
yum -y install lvm2
yum -y install ksh
yum -y install git
yum -y install libgc cpp gcc
```


> Install Java `_All nodes_`
```sh
# download java
curl -LO -H "Cookie: oraclelicense=accept-securebackup-cookie" \
            "http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.rpm"

# change file right
chmod +x jdk-8u144-linux-x64.rpm

# installation
rpm -ivh jdk-8u144-linux-x64.rpm

# check java installation
java -version

# export Java path
export JAVA_HOME=/usr/java/jdk1.8.0_144
export PATH=$JAVA_HOME/bin:$PATH  

``` 


> Reduce swappiness of the system `_All nodes_` 
```sh
# Set vm.swappiness to 10
echo 'vm.swappiness = 10' >> /etc/sysctl.conf

# initialise swap value
swapoff -a
swapon -a
``` 

> Enable NTP on the Cluster `_All nodes_` 

```sh
# install
yum -y install ntp

# check status
systemctl is-enabled ntpd

# set the NTP service to auto-start on boot
systemctl enable ntpd

# start ntp
systemctl start ntpd

# check ntp status
systemctl status ntpd

```


> Set-up FQDN `_All nodes_` 

```sh
# edit hosts file
vi /etc/hosts

# add your IP and FQDN. e.g:
145.239.155.75 hdp-1 hdp-1

# edit hostname file
vi /etc/hostname

# add your hostname
hdp-1

# check hostname
hostname -f
```


> Configure firewall `_All nodes_` 
My VMs have 2 network interface (eth0 and eth1). The eth1 interface is my VLAN network.

```sh
# check firewall status (is should be running)
firewall-cmd --state

# if firewall is not running, run this command
systemctl enable firewalld

# list all zones details
firewall-cmd --list-all-zones

# check interface zones
firewall-cmd --get-active-zones

# move eth1 to internal zone and eth0 to public zone
firewall-cmd --zone=internal --change-interface=eth1
firewall-cmd --zone=public --change-interface=eth0

# check active zone
firewall-cmd --get-active-zones

# enable hadoop port
firewall-cmd --permanent --zone=internal --add-port 1-9999/tcp

# reboot to apply change
reboot

# list all zones details
firewall-cmd --list-all-zones

```


> Disable IPv6 `_All nodes_` 

```sh
# Put the following entry to disable IPv6 for all adapter
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf

# reflect the changes
sysctl -p
``` 


> Disable SELinux, PackageKit and Check umask Value `_All nodes_` 

```sh
# desable SELinux
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 

# disable packageKit is not enabled by default
echo "enabled=0" >> /etc/yum/pluginconf.d/refresh-packagekit.conf

# set UMASK value
umask 0022
```


> Disable transparent Huge Page compaction `_All nodes_`   
```sh
# check status
cat /sys/kernel/mm/transparent_hugepage/defrag

# disable
echo never > /sys/kernel/mm/transparent_hugepage/defrag
``` 


> Set Open File Descriptors to 10000 if the current value is less that 10000 `_All nodes_`  
```sh
ulimit -Sn
ulimit -Hn
ulimit -n 10000
```


> Change hosts file to add other nodes `_All nodes_`
  Add all cluster host according to the example bellow
```sh
Example:
::1     localhost       localhost.localdomain   localhost6      localhost6.localdomain6
127.0.0.1       localhost       localhost.localdomain   localhost4      localhost4.localdomain4
#127.0.0.1      hdp-1.localdomain       hdp-1
145.239.155.75 hdp-1 hdp-1
145.239.155.75 hdp-1
145.239.155.76 hdp-2
145.239.155.78 hdp-3
```

```sh  
vi /etc/hosts
``` 


> Modify sshd_config file `_All nodes_`
- Set PermitRootLogin to yes
- Set PasswordAuthentication to yes

```sh
# create a copy of sshd_config file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# change current configuration
sed -i -e 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Restart SSH daemon
systemctl restart sshd.service

# check SSH daemon status
systemctl status sshd.service
```

> Create SSH key `_Ambari server node (hdp-1)_`

```sh
ssh-keygen
```

> Copy SSH key from ambari server to all cluster nodes `_Ambari server node (hdp-1)_`

```sh
ssh-copy-id -i /root/.ssh/id_rsa.pub root@hdp-1.c.projet-ic-166005.internal
ssh-copy-id -i /root/.ssh/id_rsa.pub root@hdp-2.c.projet-ic-166005.internal
ssh-copy-id -i /root/.ssh/id_rsa.pub root@hdp-3.c.projet-ic-166005.internal
```


> Test ssh connexion  `_Ambari server node (hdp-1)_`
```sh
ssh root@hdp-1.c.projet-ic-166005.internal
exit
ssh root@hdp-2.c.projet-ic-166005.internal
exit
ssh root@hdp-3.c.projet-ic-166005.internal
exit
``` 


> Modify sshd_config file `_All nodes_`
- Set PermitRootLogin to yes
- Set PasswordAuthentication to yes

```sh
# change current configuration
sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# Restart SSH daemon
systemctl restart sshd.service

# check SSH daemon status
systemctl status sshd.service
```

> Test ssh connexion  `_Ambari server node (hdp-1)_`
```sh
ssh root@hdp-1.c.projet-ic-166005.internal
exit
ssh root@hdp-2.c.projet-ic-166005.internal
exit
ssh root@hdp-3.c.projet-ic-166005.internal
exit
```


> Check disks  `_All nodes_`  
```sh  
# disk conf
df -h

# disk I/O speed
hdparm -t /dev/sda1

# list disks
lsblk

``` 

Your should see something like this

![MetaStore remote database](https://github.com/gamboabdoulraoufou/hdp-1-host-config/blob/master/img/disk_status.png)

> Create logical volume `_All nodes_` 
```sh
pvcreate /dev/sdb
vgcreate VolGroup01 /dev/sdb

``` 

  
> Partitione sdb disk `_All nodes_` 
```sh
# var partition for log data
lvcreate -L 200G -n lvhadoopvar   VolGroup01
mkfs -t ext4 /dev/VolGroup01/lvhadoopvar 
mkdir -p  /hadoop/var
mount /dev/VolGroup01/lvhadoopvar  /hadoop/var

# work partition for tmp storage
lvcreate -L 100G -n lvhadoopwork   VolGroup01
mkfs -t ext4 /dev/VolGroup01/lvhadoopwork 
mkdir -p  /hadoop/work
mount /dev/VolGroup01/lvhadoopwork  /hadoop/work

# usr partition code 
lvcreate -L 100G -n lvhadoopusr   VolGroup01
mkfs -t ext4 /dev/VolGroup01/lvhadoopusr 
mkdir -p  /hadoop/usr
mount /dev/VolGroup01/lvhadoopusr  /hadoop/usr

# HDFS partition for storage
lvcreate -L 1500G -n lvhadoopdata   VolGroup01
mkfs -t ext4 /dev/VolGroup01/lvhadoopdata
mkdir -p  /hadoop/data/hdfs/01
mount /dev/VolGroup01/lvhadoopdata  /hadoop/data/hdfs/01

# check partitions
lsblk

``` 

![MetaStore remote database](https://github.com/gamboabdoulraoufou/hdp-1-host-config/blob/master/img/disks_final_status2.png)


```sh
#!/bin/ksh

function create_link {
   source=$1
   source_absolute=$(echo "/$source/" | sed 's@^//*@/@')
   cible=$2
   cible_absolute=$(echo "/$cible/" | sed 's@^//*@/@')
   link=$3
   relative_link=$(echo "/$link" | sed 's@^//*@@')

   if [[ -h ${source_absolute}${relative_link} ]]
   then
      echo "Link ${source_absolute}${relative_link} already created"
   elif [[ -d ${source_absolute}${relative_link} ]]
   then
      echo "Repository ${source_absolute}${relative_link} already exists : impossible to create link!"
   else
      mkdir -p ${cible_absolute}${relative_link}
      ln -s ${cible_absolute}${relative_link} ${source_absolute}${relative_link}
      echo "Link ${source_absolute}${relative_link} created"
   fi
}

if [[ $# -ne 3 ]]
then
   echo "Usage : $0 <source> <cible> <chemin1>[,<chemin2>,...]"
   echo "Create /<source>/<chemin> to /<cible>/<chemin>"
   exit 12
fi

source=$1
cible=$2
les_chemins="$3"

for c in $(echo "$les_chemins" | sed 's@,@ @g')
    do
       create_link $source $cible $c
    done
 
```

```sh
#!/bin/ksh 
for c in usr/hdp
	   do
	      init_symlink.sh / /hadoop $c
	done


for c in falcon hdfs mapreduce oozie storm yarn zookeeper 
	   do
	      init_symlink.sh /hadoop /hadoop/work $c
	done


for c in \
	   accumulo ambari-agent ambari-infra-solr ambari-logsearch-logfeeder ambari-logsearch-portal ambari-metrics-collector \
ambari-infra-solr-client ambari-metrics-grafana ambari-metrics-monitor ambari-server atlas falcon flume hadoop hadoop-mapreduce hadoop-yarn \
	   hadoop hadoop-mapreduce hadoop-yarn \
hbase hive hive2 hive-hcatalog kafka knox livy oozie ranger service_solr spark spark2 sqoop storm webhcat zeppelin zookeeper 
	   do
	      init_symlink.sh /var/log /hadoop/var/log $c
	done


for c in ambari-agent ambari-metrics-collector ambari-metrics-monitor ambari-server \
	   atlas flume hadoop-hdfs hadoop-mapreduce hadoop-yarn hive hive2 knox oozie ranger \
	   slider smartsense spark spark2
	   do
	      init_symlink.sh /var/lib /hadoop/var/lib $c
	done
```


> Reboot `_All nodes_`   
```sh  
reboot
```
