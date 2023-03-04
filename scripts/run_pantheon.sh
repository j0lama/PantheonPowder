#!/bin/bash


# bbr copa cubic fillp fillp_sheep ledbat pcc pcc_experimental quic scream sprout taova vegas verus vivace webrtc indigo oracle
# bbr copa cubic ledbat sprout taova vegas verus vivace indigo oracle
CC_SCHEMES="bbr oracle" #copa verus
RUN_TIMES=1
NUM_FLOWS=1

if [ "$#" -gt 3 ] || [ "$#" -lt 1 ]; then
    echo "USE: $0 <Trace (PCAP or Pantheon)> <Destination IP (Only for PCAP)> <Oracle trace (optional)>"
    echo "Example: ./run_pantheon.sh /local/repository/scripts/example.pcap 155.98.38.41"
    echo "Example: ./run_pantheon.sh /local/repository/scripts/4gbusserver.pcap 155.98.38.105"
    echo "Example: ./run_pantheon.sh /usr/share/mahimahi/traces/TMobile-LTE-driving.up"
    exit 1
fi

if [ ! -f "/local/ready" ]; then
    echo "Please wait, Pantheon is being installed."
    exit 1
fi

BASE_DIR="/local"
cd $BASE_DIR
mkdir -p "tmp_pantheon_traces/"

# Get trace extension
ARG1=$1
EXTENSION="${ARG1##*.}"
if [ "$EXTENSION" == "pcap" ] && [ "$#" -lt 2 ]; then # PCAP only: show error
    echo "USE: $0 <Trace PCAP> <Destination IP> <Oracle trace (optional)>"
    echo "Example: ./run_pantheon.sh /local/repository/scripts/example.pcap 155.98.38.41"
    exit 1
elif [ "$EXTENSION" == "pcap" ] && [ "$#" -eq 2 ]; then # PCAP + IP: generate pantheon trace from pcap and generate oracle trace
    echo "Processing PCAP trace and generating oracle trace..."
    # Generating Pantheon trace out of a PCAP trace
    PCAP_BASENAME=$(basename -- "$1")
    PANTHEON_TRACE=${PCAP_BASENAME%.*}.x
    #/local/repository/scripts/pcap_to_pantheon.py $1 $2 $BASE_DIR/tmp_pantheon_traces/$PANTHEON_TRACE
    # Generate oracle trace
    #/local/repository/oracle_bbr/generate_oracle_trace.py $BASE_DIR/tmp_pantheon_traces/$PANTHEON_TRACE /local/repository/oracle_bbr/oracle.trace
    # Process PCAP and generate pantheon trace and trimmed oracle trace
    /local/repository/scripts/process_trace.py -t $1 -s $2 -p $BASE_DIR/tmp_pantheon_traces/$PANTHEON_TRACE -o /local/repository/oracle_bbr/oracle.trace
elif [ "$EXTENSION" == "pcap" ] && [ "$#" -eq 3 ]; then # PCAP + IP + Oracle trace: generate pantheon trace from pcap
    echo "Processing PCAP trace..."
    # Generating Pantheon trace out of a PCAP trace
    PCAP_BASENAME=$(basename -- "$1")
    PANTHEON_TRACE=${PCAP_BASENAME%.*}.x
    #/local/repository/scripts/pcap_to_pantheon.py $1 $2 $BASE_DIR/tmp_pantheon_traces/$PANTHEON_TRACE
    # Generate Pantheon trace from PCAP
    /local/repository/scripts/process_trace.py -t $1 -s $2 -p $BASE_DIR/tmp_pantheon_traces/$PANTHEON_TRACE
    # Copy Oracle trace to destination and trim
    #cp $3 /local/repository/oracle_bbr/oracle.trace
    #python /local/repository/scripts/trim_trace.py /local/repository/oracle_bbr/oracle.trace 3.128
    # Trim oracle trace
    /local/repository/scripts/process_trace.py -t $3 -o /local/repository/oracle_bbr/oracle.trace
else # Pantheon trace
    echo "Processing Pantheon trace..."
    PCAP_BASENAME=$(basename -- "$1")
    PANTHEON_TRACE=${PCAP_BASENAME%.*}.x
    #cp $1 $BASE_DIR/tmp_pantheon_traces/$PANTHEON_TRACE
    # Generate oracle trace
    #/local/repository/oracle_bbr/generate_oracle_trace.py $BASE_DIR/tmp_pantheon_traces/$PANTHEON_TRACE /local/repository/oracle_bbr/oracle.trace
    # From pantheon trace, generate pantheon trace and trimmed oracle trace
    /local/repository/scripts/process_trace.py -t $1 -p $BASE_DIR/tmp_pantheon_traces/$PANTHEON_TRACE -o /local/repository/oracle_bbr/oracle.trace
fi


# Compile and install BBR Oracle
cd /local/repository/oracle_bbr/
TRACE="/local/repository/oracle_bbr/oracle.trace"
echo "[ORACLE] Deploying oracle using $TRACE"
while [ "$(lsmod | grep oracle | awk '{print $3}')" == "1" ]; do
    echo "Waiting to unload Oracle kernel module..."
    sleep 1
done
make
lsmod | grep "oracle" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    sudo rmmod oracle
fi
sudo insmod oracle.ko filename=$TRACE lines=$(wc -l < ${TRACE} | awk '{print $1}')


cd $BASE_DIR

# Emulate with Pantheon
mkdir -p outputs/
PANTHEON_OUTPUT_DIR=$BASE_DIR/outputs/${PANTHEON_TRACE%.*}
rm -Rf $PANTHEON_OUTPUT_DIR 2> /dev/null
mkdir $PANTHEON_OUTPUT_DIR

cd pantheon/
./src/experiments/test.py local --schemes "$CC_SCHEMES" --uplink-trace $BASE_DIR/tmp_pantheon_traces/$PANTHEON_TRACE --data-dir $PANTHEON_OUTPUT_DIR --run-times $RUN_TIMES -f $NUM_FLOWS

# Analyze emulation
./src/analysis/analyze.py --data-dir $PANTHEON_OUTPUT_DIR

date
echo ""
echo ""
echo "Pantheon emulation completed using: $CC_SCHEMES"
echo "Run the following command to get the report:"
echo "scp $(whoami)@$(hostname):$PANTHEON_OUTPUT_DIR/pantheon_report.pdf ."
