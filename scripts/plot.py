import matplotlib.pyplot as plt
import sys
import pandas as pd

packet_size = 1500*8
window = 100
trim = 4
diag_trim = 3.97

def read_pantheon(path):
    tmp = []
    with open(path, 'r') as f:
        lines = f.readlines()
        for l in lines:
            tmp.append(int(l))
    tput = [0,]*(max(tmp)+1)
    for v in tmp:
        tput[v] += packet_size*1000
    
    return pd.DataFrame(tput).iloc[:, 0].rolling(30, min_periods=1).mean().values.tolist()

def read_oracle(path):
    tmp = []
    with open(path, 'r') as f:
        lines = f.readlines()
        for l in lines:
            tmp.append(int(l))
    return tmp

def read_diag(path):
    tmp = []
    with open(path, 'r') as f:
        lines = f.readlines()
        for l in lines:
            tmp.append(int(l))
    return tmp[int(trim*1000):]

if len(sys.argv) < 3 or len(sys.argv) > 4:
    print('USE: {0} <Pantheon> <Oracle> <diag (optional) >'.format(sys.argv[0]))
    exit(1)

# PCAP
pan_tp = read_pantheon(sys.argv[1])
pan_ts = [x/1000 for x in range(len(pan_tp))]
# Oracle
ora_tp = read_oracle(sys.argv[2])
ora_ts = [x/1000+trim for x in range(len(ora_tp))]

plt.plot(pan_ts, pan_tp, label='Pantheon', color='green', linewidth=0.6)
plt.plot(ora_ts, ora_tp, label='Oracle', color='red', linewidth=0.6)
# Diag
if len(sys.argv) > 3:
    diag_tp = read_diag(sys.argv[3])
    diag_ts = [x/1000+diag_trim for x in range(len(diag_tp))]
    plt.plot(diag_ts, diag_tp, label='Diag', color='blue', linewidth=0.6)
plt.xlabel("Time", fontsize=15)
plt.ylabel("bps", fontsize=15)
leg = plt.legend(fontsize=14)
plt.grid()
plt.show()