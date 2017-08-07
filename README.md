## HDP-1-host-config

> Configuration
- 4 VMs on google compute Engine (3 VM for Hadoop Cluster and 1 VM for data backup and micro services)
- OS: CentOS 7
- RAM: 20Go
- CPU: 6
- Boot disk: 200Go
- Attached disk: 2500G

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


> Disable IPv6 `_All nodes_` 

```sh
# Put the following entry to disable IPv6 for all adapter
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf

# reflect the changes
sysctl -p
``` 

> Disable SELinux `_All nodes_` 

```sh
sed -i -e 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 

```

> Disable transparent Huge Page compaction `_All nodes_`   
```sh
# check stétus
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

> Change hosts file `_All nodes_`
  Add all cluster host according to the example bellow
```sh
Example:
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.132.0.22 instance-2.c.equipe-1314.internal instance-2  # Added by Google
169.254.169.254 metadata.google.internal  # Added by Google 
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
ssh root@hdp-4.c.projet-ic-166005.internal
exit
``` 

> Modify sshd_config file again `_All nodes_`
- Set PasswordAuthentication to no

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
ssh root@hdp-4.c.projet-ic-166005.internal
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
lvcreate -L 300G -n lvhadoopvar   VolGroup01
mkfs -t ext4 /dev/VolGroup01/lvhadoopvar 
mkdir -p  /hadoop/var
mount /dev/VolGroup01/lvhadoopvar  /hadoop/var

# work partition for tmp storage
lvcreate -L 200G -n lvhadoopwork   VolGroup01
mkfs -t ext4 /dev/VolGroup01/lvhadoopwork 
mkdir -p  /hadoop/work
mount /dev/VolGroup01/lvhadoopwork  /hadoop/work

# usr partition code 
lvcreate -L 100G -n lvhadoopusr   VolGroup01
mkfs -t ext4 /dev/VolGroup01/lvhadoopusr 
mkdir -p  /hadoop/usr
mount /dev/VolGroup01/lvhadoopusr  /hadoop/usr

# HDFS partition for storage
lvcreate -L 1800G -n lvhadoopdata   VolGroup01
mkfs -t ext4 /dev/VolGroup01/lvhadoopdata
mkdir -p  /hadoop/data/hdfs/01
mount /dev/VolGroup01/lvhadoopdata  /hadoop/data/hdfs/01

# check partitions
lsblk

``` 

![MetaStore remote database](https://github.com/gamboabdoulraoufou/hdp-1-host-config/blob/master/img/disks_final_status2.png)

 

> Reboot `_All nodes_`   
```sh  
reboot
```

> Disable firewall `_All nodes_` 

```sh 
# check firewall status
systemctl status firewalld

# disbale firewall
systemctl stop firewalld

# check firewall status
systemctl status firewalld
```
