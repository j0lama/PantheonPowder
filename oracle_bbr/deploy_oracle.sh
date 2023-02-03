#!/bin/bash

if [ ! -f "/local/repository/oracle_bbr/oracle.trace" ]; then
    echo "Error: no oracle.trace in /local/repository/oracle_bbr/."
    exit 1
fi

KVERSION=$(shell uname -r)
fpath="/local/repository/oracle_bbr/oracle.trace"

echo "Using $fpath as filepath..."
flen=$(wc -l < ${fpath})
longestline=$(wc -L < ${fpath})
fsize=$(wc -c < ${fpath})

echo $fpath
echo "file length: "$flen
echo "longest line: "$longestline
echo "file size: "$fsize

# Compile bbr oracle
make

sudo cp oracle.ko /lib/modules/$(KVERSION)/kernel/net/ipv4/oracle.ko
sudo rmmod /lib/modules/$(KVERSION)/kernel/net/ipv4/oracle.ko
sudo insmod /lib/modules/$(KVERSION)/kernel/net/ipv4/oracle.ko filename=$fpath filesize=$fsize filelen=$flen longestline=$longestline