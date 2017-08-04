## HDP-1-host-config

> Configuration
- 4 VMs on google compute Engine (3 VM for Hadoop Cluster and 1 VM for data backup and micro service)
- OS: CentOS 7
- RAM: 15Go
- CPU: 4
- Boot disk: 100Go
- Attached disk: 200G

> Cluster model

![MetaStore remote database](https://github.com/gamboabdoulraoufou/hdp-1-host-config/blob/master/img/archi.png)

  
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
# edit /etc/sysctl.cof file
vi /etc/sysctl.conf

# Set vm.swappiness to 10 by adding the value bellow
vm.swappiness = 10

# initialise swap value
swapoff -a
swapon -a
``` 


> Disable IPv6 `_All nodes_` 

```sh
# edit /etc/sysctl.conf file
vi /etc/sysctl.conf

# Put the following entry to disable IPv6 for all adapter
net.ipv6.conf.all.disable_ipv6 = 1

# reflect the changes
sysctl -p
``` 

> Disable SELinux `_All nodes_` 

```sh
# edit config file
vi /etc/selinux/config 

# set this config
SELINUX=disabled
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

# Edit sshd_config file and change current configuration
vi /etc/ssh/sshd_config

# change config, save and quit

# Restart SSH daemon
/bin/systemctl restart sshd.service

# check SSH daemon status
/bin/systemctl status sshd.service
```

> Create SSH key `_Ambari server node (instance-1)_`

```sh
ssh-keygen
```

> Copy SSH key from ambari server to all cluster nodes `_Ambari server node (instance-1)_`

```sh
ssh-copy-id -i /root/.ssh/id_rsa.pub root@instance-1.c.equipe-1314.internal
ssh-copy-id -i /root/.ssh/id_rsa.pub root@instance-2.c.equipe-1314.internal
ssh-copy-id -i /root/.ssh/id_rsa.pub root@instance-3.c.equipe-1314.internal
```

> Test ssh connexion  `_Ambari server node (instance-1)_`
```sh
ssh root@instance-1.c.equipe-1314.internal
exit
ssh root@instance-2.c.equipe-1314.internal
exit
ssh root@instance-3.c.equipe-1314.internal
exit
``` 

> Modify sshd_config file again `_All nodes_`
- Set PasswordAuthentication to no

```sh
# Edit sshd_config file and change current configuration
vi /etc/ssh/sshd_config

# change config, save and quit

# Restart SSH daemon
/bin/systemctl restart sshd.service

# check SSH daemon status
/bin/systemctl status sshd.service
```


> Test ssh connexion  `_Ambari server node (instance-1)_`
```sh
ssh root@instance-1.c.equipe-1314.internal
exit
ssh root@instance-2.c.equipe-1314.internal
exit
ssh root@instance-3.c.equipe-1314.internal
exit
``` 


> copy scripts folder on each node  `_All_nodes_`
```sh
cd
mkdir -p config_host/
gsutil cp -r gs://velvet-packages-v2/hdp-installation/* .
mv bash config_host/bash
chmod +x config_host/bash/*
ll config_host/bash
```


> Create users and groups `_All nodes_` 

```sh
# go to the script folder
cd
cd config_host/bash

# launght script
bash create_users_and_groups.sh

# 
cut -d: -f1 /etc/passwd

```


> Create user folders and set permissions `_All_nodes_`

```sh
# go to the script folder
cd
cd config_host/bash

# launght script
bash create_folders_and_permission.sh

# check folders and users
ll /home

```
![MetaStore remote database](https://github.com/gamboabdoulraoufou/hdp-1-host-config/blob/master/img/scripts.png)

> Check disks  `_All nodes_`  
```sh  
# disk conf
df -h

# disk I/O speed
hdparm -t /dev/sda1

# list disks
lsblk

``` 

![MetaStore remote database](https://github.com/gamboabdoulraoufou/hdp-1-host-config/blob/master/img/disks_initial_status.png)


> Create logical volume `_All nodes_` 
```sh
# go to the script folder
cd
cd config_host/bash

# launght script
bash create_lvm.sh

``` 

> Create disk partition `_All nodes_` 
```sh
# go to the script folder
cd
cd config_host/bash

# launght script
## execute this command on datanode
bash create_partitions.sh 'yes'

## execute this command on non-datanode
bash create_partitions.sh 'no'

# check disks status
lsblk

``` 

![MetaStore remote database](https://github.com/gamboabdoulraoufou/hdp-1-host-config/blob/master/img/disks_final_status.png)


> Create symbolic link to map partitions and services `_All nodes_` 
```sh
# go to the script folder
cd
cd config_host/bash

# launght script
ksh init_hadoop.sh

# check links
ll /hadoop/

``` 


> Reboot `_All nodes_`   
```sh  
reboot
``` 
