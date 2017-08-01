#!/bin/sh

grep -i ' '$(hostname)  /etc/hosts| awk '{print $2}'| tr 'A-Z' 'a-z'
