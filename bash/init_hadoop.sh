#!/bin/ksh

PATH=$(dirname $0):$PATH

if [[ $# -ne 1 ]]
then
   echo "Usage : $0 <serveur ambari>"
   echo "initialise les arborescences de fichiers hadoop"
   exit 12
fi

# -------------------------------------------------------
# /

for c in \
usr/hdp \

do
   init_symlink.sh / /hadoop $c
done

# -------------------------------------------------------
# /usr/hadoop

mkdir -p /usr/hadoop
for c in \
falcon \
hdfs \
oozie \
storm \
yarn \
zookeeper \

do
   init_symlink.sh /usr/hadoop /hadoop/work $c
done

# -------------------------------------------------------
# /var/lib

for c in \
ambari-agent \
ambari-metrics-collector \
ambari-metrics-grafana \
ambari-metrics-monitor \
ambari-server \
atlas \
flume \
hadoop-hdfs \
hadoop-mapreduce \
hadoop-yarn \
hive \
hive2 \
knox \
oozie \
ranger \
slider \
smartsense \
spark \
spark2 \

do
   init_symlink.sh /var/lib /hadoop/var/lib $c
done

# -------------------------------------------------------
# /var/log

for c in \
accumulo \
ambari-agent \
ambari-infra-solr \
ambari-logsearch-logfeeder \
ambari-logsearch-portal \
ambari-metrics-collector \
ambari-metrics-grafana \
ambari-metrics-monitor \
ambari-server \
atlas \
falcon \
flume \
hadoop \
hadoop-mapreduce \
hadoop-yarn \
hbase \
hive \
hive2 \
hive-hcatalog \
kafka \
knox \
livy \
oozie \
ranger \
service_solr \
spark \
spark2 \
sqoop \
storm \
webhcat \
zeppelin \
zookeeper \

do
   init_symlink.sh /var/log /hadoop/var/log $c
done

# -------------------------------------------------------
# /hadoop

for c in \
falcon \
hdfs \
mapreduce \
oozie \
storm \
yarn \
zookeeper \

do
   init_symlink.sh /hadoop /hadoop/work $c
done

# -------------------------------------------------------
# /etc/solr

mkdir -p /hadoop/work/solr /etc/solr
for c in \
data_dir \

do
   init_symlink.sh /etc/solr /hadoop/work/solr $c
done

# -------------------------------------------------------

mkdir -p /var/run/ambari-server
chown ambari2:hadoop /hadoop/var/log/ambari-server /hadoop/var/log/ambari-agent /var/run/ambari-server

if [[ -d /hadoop/data/hdfs/01 ]]
then
   chown hdfs:hadoop /hadoop/data/hdfs/01
   chmod 750 /hadoop/data/hdfs/01
fi

mkdir -p /hadoop/work/yarn/local /hadoop/var/yarn/log
chown yarn:hadoop /hadoop/work/yarn/local /hadoop/var/yarn/log
chmod 750 /hadoop/work/yarn/local /hadoop/var/yarn/log

mkdir -p /var/run/hadoop-mapreduce/yarn /hadoop/log/hadoop-mapreduce/yarn

chown yarn:hadoop /var/run/hadoop-mapreduce/yarn /hadoop/log/hadoop-mapreduce/yarn

chown ranger:hadoop /hadoop/var/log/ranger

mkdir -p /hadoop/work/tmp/ambari-qa/staging

chown ambari-qa:users /hadoop/work/tmp/ambari-qa/staging

cp /home/ec2-user/scripts/hostname.sh /var/lib/ambari-agent
chown ambari2 /var/lib/ambari-agent/hostname.sh
chmod 700 /var/lib/ambari-agent/hostname.sh
