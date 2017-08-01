#!/bin/bash

mkdir -p /home/falcon
mkdir -p /home/flume
mkdir -p /home/hbase
mkdir -p /home/hcat
mkdir -p /home/hdfs
mkdir -p /home/hive
mkdir -p /home/kafka
mkdir -p /home/knox
mkdir -p /home/mapred
mkdir -p /home/oozie
mkdir -p /home/ranger
mkdir -p /home/spark
mkdir -p /home/sqoop
mkdir -p /home/storm
mkdir -p /home/tez
mkdir -p /home/yarn
mkdir -p /home/zookeeper
mkdir -p /home/zeppelin
mkdir -p /home/infra-solr
mkdir -p /home/solr

chown falcon:hadoop /home/falcon
chown flume:hadoop /home/flume
chown hbase:hadoop /home/hbase
chown hcat:hadoop /home/hcat
chown hdfs:hadoop /home/hdfs
chown hive:hadoop /home/hive
chown kafka:hadoop /home/kafka
chown knox:hadoop /home/knox
chown mapred:hadoop /home/mapred
chown oozie:hadoop /home/oozie
chown ranger:hadoop /home/ranger
chown spark:hadoop /home/spark
chown sqoop:hadoop /home/sqoop
chown storm:hadoop /home/storm
chown tez:hadoop /home/tez
chown yarn:hadoop /home/yarn
chown zookeeper:hadoop /home/zookeeper
chown infra-solr:hadoop /home/infra-solr
chown solr:hadoop /home/solr

echo "@hadoop          hard    nofile          10000" >/etc/security/limits.d/hadoop.conf
echo "@hadoop          soft    nofile          10000" >>/etc/security/limits.d/hadoop.conf
