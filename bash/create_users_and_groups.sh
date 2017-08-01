#!/bin/bash

groupadd hadoop
groupadd analyst

analyst -G analyst data_tech
analyst -G analyst data_tech

useradd -G hadoop accumulo
useradd -G hadoop ambari2
useradd -G hadoop ambari-qa
useradd -G hadoop ams
useradd -G hadoop atlas
useradd -G hadoop falcon
useradd -G hadoop flume
useradd -G hadoop hbase
useradd -G hadoop hcat
useradd -G hadoop hdfs
useradd -G hadoop hive
useradd -G hadoop kafka
useradd -G hadoop kms
useradd -G hadoop knox
useradd -G hadoop mahout
useradd -G hadoop mapred
useradd -G hadoop oozie
useradd -G hadoop ranger
useradd -G hadoop spark
useradd -G hadoop sqoop
useradd -G hadoop storm
useradd -G hadoop tez
useradd -G hadoop yarn
useradd -G hadoop zookeeper
useradd -G hadoop livy
useradd -G hadoop zeppelin
useradd -G hadoop infra-solr
useradd -G hadoop solr
useradd -G hadoop smartsense
useradd -G hadoop logsearch

