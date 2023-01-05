#!/bin/sh
sudo sysctl -w net.ipv4.ip_forward=1
src/experiments/setup.py --schemes "cubic sprout vivace verus copa tcp-beta"
