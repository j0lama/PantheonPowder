#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "USE: $0 <PCAP trace> <Destination IP>"
    echo "Example: ./run_pantheon.sh example.pcap 155.98.38.41"
    exit 1
fi

BASE_DIR="/local/repository/scripts"

cd $BASE_DIR

# Generating Pantheon trace out of a PCAP trace
mkdir -p "$BASE_DIR/tmp_pantheon_traces/"
PCAP_BASENAME=$(basename -- '$1')
PANTHEON_TRACE="${PCAP_BASENAME%.*}.x"
./pcap_to_pantheon.py $1 $2 tmp_pantheon_traces/$PANTHEON_TRACE

# Emulate with Pantheon
cd pantheon
mkdir -p outputs/
PANTHEON_OUTPUT_DIR="outputs/${PANTHEON_TRACE%.*}"
rm -Rf $PANTHEON_OUTPUT_DIR 2> /dev/null
mkdir $PANTHEON_OUTPUT_DIR
CC_SCHEMES="sprout cubic verus"
echo "Schemes used: $CC_SCHEMES"
/src/experiments/test.py local --schemes $CC_SCHEMES --uplink-trace tmp_pantheon_traces/$PANTHEON_TRACE --data-dir $PANTHEON_OUTPUT_DIR

# Analyze emulation
src/analysis/analyze.py --data-dir $PANTHEON_OUTPUT_DIR