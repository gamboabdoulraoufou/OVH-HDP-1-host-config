#!/bin/bash

pvcreate /dev/sdb
vgcreate VolGroup01 /dev/sdb
