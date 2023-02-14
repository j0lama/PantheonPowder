#!/usr/bin/env python

import numpy as np
import csv
import sys

DEFAULT_MSS = 1500 * 8

# This is the default value that Pantheon uses. In other words,
#each bin will correspond to 0.5s
def ms_to_bin(timestamp, first_timestamp, ms_per_bin):
    return int((timestamp - first_timestamp)/ms_per_bin)

def bin_to_sec(bin_ID, ms_per_bin):
    return bin_ID * ms_per_bin / 1000

def getTimestamp(line):
    return float(line)

def getSize(line):
    pass

def get_bin_capacities(file, ms_per_bin):
    capacities = {}

    # Read lines
    with open(file) as f:
        lines = f.readlines()

    # Get first timestamp
    first_timestamp = getTimestamp(lines[0])

    for line in lines:
        timestamp = float(line)
        bits = DEFAULT_MSS

        bin_ID = ms_to_bin(timestamp, first_timestamp, ms_per_bin)
        capacities[bin_ID] = capacities.get(bin_ID, 0) + bits
    return capacities


def convert_bins_into_link_rate(capacities, ms_per_bin):
    bins = capacities.keys()
    link_capacity = []
    link_capacity_times = []
    
    for bin_ID in range(min(bins), max(bins) + 1):
        #Note the division by ms_per_bin*1000 is to convert to Mbps
        link_capacity.append(capacities.get(bin_ID, 0) / (ms_per_bin*1000))
        link_capacity_times.append(bin_to_sec(bin_ID, ms_per_bin))
    
    return link_capacity, link_capacity_times

def generate_oracle_timeseries(rate, ms_per_bin):
    trim = 3.030
    N = 1
    avg_rate = np.convolve(rate, np.ones((N,))/N, mode='valid')
    oracle_rate = []
    for r in avg_rate:
        oracle_rate += [r, ] * ms_per_bin
    oracle_time = [x/1000 for x in range(len(oracle_rate))]
    return oracle_rate[int(trim*1000):], [x-trim for x in oracle_time[int(trim*1000):]]

def process_trace(file, ms_per_bin=500):
    capacities = get_bin_capacities(file, ms_per_bin)
    rate, time = convert_bins_into_link_rate(capacities, ms_per_bin)
    oracle_rate, oracle_time = generate_oracle_timeseries(rate, ms_per_bin)
    return rate, time, oracle_rate, oracle_time

def oracle_to_file(output, oracle_rate):
    with open(output, 'w') as f:
        for rate in oracle_rate:
            f.write('{0}\n'.format(rate))

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('USE: python {0} <Pantheon trace> <Oracle trace output>'.format(sys.argv[0]))
        exit()
    
    # Get time series
    rate, time, oracle_rate, oracle_time = process_trace(sys.argv[1], 50)
    oracle_to_file(sys.argv[2], [int(x*1000000) for x in oracle_rate])