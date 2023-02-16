#!/usr/bin/env python3

import sys
import subprocess

def tshark(pcap, ip):
    cmd = 'tshark -r {0} -Y "ip.dst == {1} && not(tcp.analysis.retransmission || tcp.analysis.fast_retransmission) && not(ssh)" -T fields -e frame.time_relative -e frame.len'.format(pcap, ip)
    output = subprocess.check_output(cmd, shell=True).strip().decode()
    return output.splitlines()

def generateOutput(lines, file):
    output = ''
    for l in lines:
        val = int(float(l.split()[0])*1000)
        output += str(val) + '\n'
    with open(file, 'w') as f:
        f.write(output)

def generateOutputNoGaps(lines, file):
    output = ''
    vals = {}
    for l in lines:
        v = int(float(l.split()[0])*1000)
        if v in vals:
            vals[v] += 1
        else:
            vals[v] = 1
    for i in range(v):
        if not i in vals:
            vals[i] = 1
    for i in range(v):
        for j in range(vals[i]):
            output += str(i) + '\n'
    
    with open(file, 'w') as f:
        f.write(output)

if __name__ == '__main__':
    if len(sys.argv) != 4:
        print('USE: {0} <PCAP file> <Destination IP> <Output File (Pantheon trace)>'.format(sys.argv[0]))
        exit(1)
    lines = tshark(sys.argv[1], sys.argv[2])
    generateOutput(lines, sys.argv[3])

