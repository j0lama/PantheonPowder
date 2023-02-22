#!/usr/bin/env python

import subprocess
import argparse
import pandas as pd
import math

window = 100
fixed_pkt_size = False
packet_size = 1500*8
trim = 3.128
max_ts_len = 40000

def store_trace(path, tp):
    with open(path, 'w') as f:
        for value in tp:
            f.write('{0}\n'.format(value))

def process_pcap(pcap, ip):
    cmd = 'tshark -r {0} -Y "ip.dst == {1} && not(tcp.analysis.retransmission || tcp.analysis.fast_retransmission) && not(ssh)" -T fields -E separator=, -e frame.time_relative -e frame.len'.format(pcap, ip)
    output = subprocess.check_output(cmd, shell=True).strip().decode()
    lines = output.splitlines()
    endTS = math.floor(float(lines[-1].split(',')[0])*1000)+1
    tput = [0,]*endTS
    for line in lines:
        time, tp = line.split(',')
        if fixed_pkt_size:
            tput[math.floor(float(time)*1000)] += packet_size*8
        else:
            tput[math.floor(float(time)*1000)] += int(tp)*8
    # Trim tput timeserie to 40 seconds
    tput = tput[:max_ts_len]
    return pd.DataFrame(tput).iloc[:, 0].rolling(window, min_periods=1).mean()

def process_pantheon_trace(pan_trace):
    with open(pan_trace, 'r') as f:
        lines = f.readlines()
        trace = []
        for l in lines:
            trace.append(l)
    tput = [0,]*max(trace)
    for v in trace:
        tput[v] += 1
    tput = tput[:max_ts_len]
    return pd.DataFrame(tput).iloc[:, 0].rolling(window, min_periods=1).mean()

def process_oracle_trace(oracle_trace):
    pass
    

def generate_pantheon_trace(tp, pantheon_out):
    freq = [0,]*len(tp)
    for i in range(len(tp)):
        freq[i] = math.ceil(tp[i]/packet_size)
    trace = []
    for i in range(len(freq)):
        for j in range(freq[i]):
            trace.append(i)
    store_trace(pantheon_out, trace)


def generate_oracle_trace(tp, oracle_out):
    tp = tp[trim:]
    store_trace(oracle_out, tp)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--trace')
    parser.add_argument('-s', '--server-ip', help='IP address of the server (PCAP only)')
    parser.add_argument('-p', '--pantheon-output', help='Destination for the Pantheon trace')
    parser.add_argument('-o', '--oracle-output', help='Destination for the Oracle trace')
    args = parser.parse_args()
    
    if args.trace.endswith('.pcap') and args.server_ip and args.pantheon_output:
        ts = process_pcap(args.trace, args.server_ip)
        generate_pantheon_trace(ts, args.pantheon_output)
        if args.oracle_output:
            generate_oracle_trace(ts, args.oracle_output)
    # Generate a pantheon trace from a pantheon trace
    elif not args.trace.endswith('.pcap') and args.pantheon_output:
        ts = process_pantheon_trace(args.trace)
        generate_pantheon_trace(ts, args.pantheon_output)
        if args.oracle_output:
            generate_oracle_trace(ts, args.oracle_output)
    # Generate a trimmed oracle trace from an oracle trace
    elif not args.trace.endswith('.pcap') and args.oracle_output:
        ts = process_oracle_trace(args.trace)
        generate_oracle_trace(ts, args.oracle_output)