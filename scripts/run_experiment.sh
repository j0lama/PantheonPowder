cd pantheon/DIR

rm *

cd ..

#sudo src/experiments/setup.py --setup --schemes "sprout sprout-ewma sprout-ma sprout-sewma"


#src/experiments/test.py local --schemes "sprout sprout-ewma cubic" --uplink-trace /usr/share/mahimahi/traces/ATT-LTE-driving.up --downlink-trace /usr/share/mahimah$
src/experiments/test.py local --schemes "sprout sprout-ma cubic" --uplink-trace /usr/share/mahimahi/traces/TMobile-LTE-driving.up --downlink-trace /usr/share/mahima$

#src/experiments/test.py local --schemes "sprout sprout-ma cubic" --uplink-trace /usr/share/mahimahi/traces/TMobile-UMTS-driving.up --downlink-trace /usr/share/mahi$


src/analysis/analyze.py --data-dir DIR
