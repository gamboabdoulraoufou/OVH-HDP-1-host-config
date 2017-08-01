## cdh-host-config

> Configuration
- 3 VMs on google compute Engine
- OS: CentOS 7
- RAM: 7.5Go
- CPU: 2
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
yum -y install openssh
yum -y install openssh-client
yum -y install openssh-server
yum -y install ssh 
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
            "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm"

# change file right
chmod +x jdk-8u131-linux-x64.rpm

# installation
rpm -ivh jdk-8u131-linux-x64.rpm

# check java installation
java -version

# export Java path
export JAVA_HOME=/usr/java/jdk1.8.0_131
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
sudo systemctl stop firewalld
sudo systemctl disable firewalld

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

> Disable transparent Huge Page compaction  
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
systemctl restart  sshd.service
```

> Create SSH key `_Master nodes (node 2 and 3 in this case) Only_`

```sh
ssh-keygen
```

> Copy SSH key from master node to all slave nodes `_Master nodes (node 2 and 3 in this case) Only_`

```sh
ssh-copy-id -i /root/.ssh/id_rsa.pub root@instance-1.c.equipe-1314.internal
ssh-copy-id -i /root/.ssh/id_rsa.pub root@instance-2.c.equipe-1314.internal
ssh-copy-id -i /root/.ssh/id_rsa.pub root@instance-3.c.equipe-1314.internal
```

> Test ssh connexion  `_Master_node_`
```sh
ssh root@instance-1.c.equipe-1314.internal
exit
ssh root@instance-2.c.equipe-1314.internal
exit
ssh root@instance-3.c.equipe-1314.internal
exit
``` 

> Recover sshd_config initial config `_Master nodes_`
```sh
# Edit sshd_config file and change current configuration
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_bis
mv /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
  
# Restart SSH daemon
service sshd restart
```

> Test ssh connexion again  `_Master_node_`
```sh
ssh root@instance-1
exit
ssh root@instance-2
exit
ssh root@instance-3
exit


> Check disks  `_All nodes_`  
```sh  
# disk conf
df -h

# disk I/O speed
hdparm -t /dev/sda1

# list disk
lsblk
``` 

> copy scripts folder on each node  
```sh
gsutil cp gs://velvet-packges/config_host/* .
```

> Create logical volume  
```sh
cd
cd scripts
bash create_lvm.sh
``` 

> Create disk partition  
```sh
cd
cd scripts

# execute this script on datanode
bash create_partitions.sh 'yes'

# execute this script on non-datanode
bash create_partitions.sh 'no'
 ``` 
 
> Create symbolic link to map partitions and services
```sh
cd
cd scripts

# create user folders
bash socle_big_data.sh

# create 
ksh init_hadoop.sh instance-1
``` 

> Reboot `_All nodes_`   
```sh  
reboot
``` 
