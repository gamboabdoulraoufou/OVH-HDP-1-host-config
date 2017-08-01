## cdh-1-host-config

> Configuration
- 3 VMs on google compute Engine
- OS: CentOS 6
- RAM: 15Go
- CPU: 4
- Boot disk: 100Go
- Attached disk: 200G


### 0- Pre-requisites  
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

> Disable Firewalld `_All nodes_` 
```sh
service stop firewalld
systemctl disable firewalld

# check firewall status
sudo firewall-cmd --state
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
  
# Restart SSH daemon
service sshd restart
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

> Recover sshd_config initial config `_Ambari server node (instance-1)_`
```sh
# Edit sshd_config file and change current configuration
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_bis
mv /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
  
# Restart SSH daemon
service sshd restart
```

> Test ssh connexion again `_Ambari server node (instance-1)_`
```sh
ssh root@instance-1
exit
ssh root@instance-2
exit
ssh root@instance-3
exit

``` 


> copy scripts folder on each node  `_All_nodes_`
```sh
gsutil cp gs://velvet-packges/config_host/* .
```


> Create services folder `_All_nodes_`

```sh
# go to the script folder
cd
cd config_host/bash

# launght script
bash create_folders.sh

```


> Create user group and assign users to groups `_All nodes_` 

```sh
# go to the script folder
cd
cd config_host/bash

# launght script
bash create_users_groups.sh

# 
cut -d: -f1 /etc/passwd

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

``` 
 
> Create symbolic link to map partitions and services `_All nodes_` 
```sh
# go to the script folder
cd
cd config_host/bash

# launght script
ksh init_hadoop.sh instance-1

``` 

> Reboot `_All nodes_`   
```sh  
reboot
``` 
