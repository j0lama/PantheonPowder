#!/bin/sh

cd pantheon

sudo sysctl -w net.ipv4.ip_forward=1

cd src/wrappers/

chmod 755 sprout-ewma.py
chmod 755 sprout-ma.py
chmod 755 sprout-sewma.py
chmod 755 sprout-oracle.py

cd ..
cd ..

chmod -R 755 third_party/sprout-ewma/
chmod -R 755 third_party/sprout-ma/
chmod -R 755 third_party/sprout-sewma/
chmod -R 755 third_party/sprout-oracle/

src/experiments/setup.py --schemes "cubic sprout vivace verus copa"
