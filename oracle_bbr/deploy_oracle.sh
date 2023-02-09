#!/bin/bash

if [ ! -f "/local/repository/oracle_bbr/oracle.trace" ]; then
    echo "Error: no oracle.trace in /local/repository/oracle_bbr/."
    exit 1
fi

TRACE="/local/repository/oracle_bbr/oracle.trace"
echo "[ORACLE] Deploying oracle using $TRACE"

# Compile bbr oracle
make

# Check if module is loaded
lsmod | grep "oracle" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    sudo rmmod oracle
fi

sudo insmod oracle.ko filename=$TRACE lines=$(wc -l < ${TRACE} | awk '{print $1}')