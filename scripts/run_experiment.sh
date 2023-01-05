cd pantheon

src/experiments/setup.py --setup --schemes "sprout sprout-ewma sprout-ma sprout-sewma"


#src/experiments/test.py local --schemes "sprout sprout-ewma cubic" --uplink-trace /usr/share/mahimahi/traces/ATT-LTE-driving.up --downlink-trace /usr/share/mahimahi/traces/ATT-LTE-driving.down --data-dir DIR
src/experiments/test.py local --schemes "sprout-ewma sprout-ma" --uplink-trace /usr/share/mahimahi/traces/TMobile-LTE-driving.up --downlink-trace /usr/share/mahimahi/traces/TMobile-LTE-driving.down --data-dir DIR

#src/experiments/test.py local --schemes "sprout sprout-ewma cubic" --uplink-trace /usr/share/mahimahi/traces/TMobile-UMTS-driving.up --downlink-trace /usr/share/mahimahi/traces/TMobile-UMTS-driving.down --data-dir DIR


src/analysis/analyze.py --data-dir DIR
