# PantheonPowder

### How to use it?
First, send the pcap file to the powder machine. Then go to the scripts folder and execute the following:
```bash
cd /local/repository/scripts/
./run_pantheon.sh <PCAP trace> <Destination IP>
```

It will take a couple of minutes. Once it finsih it will show the command to get the report (PDF) in your machine.

## BBR Oracle

### Best configurations

##### 100ms bins
trim = 3.128
convolution = [0.15, 0.7, 0.15]

##### Best
trim = 3.128
convolution = np.ones((N,))/N with N = 3
bin size = 60