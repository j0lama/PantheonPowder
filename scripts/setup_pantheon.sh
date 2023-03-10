#!/bin/bash

CC_SCHEMES="bbr copa cubic fillp fillp_sheep ledbat pcc pcc_experimental quic scream sprout taova vegas verus vivace webrtc indigo oracle"

if [ -f "/local/ready" ]; then
    echo "Pantheon already installed."
    cd /local/pantheon
    src/experiments/setup.py --schemes "$CC_SCHEMES"
    exit 1
fi

BASE_DIR="/local"

# Update repositories
sudo apt update -y

# Install dependencies
sudo apt install -y python-yaml python-pip mahimahi texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra iperf3
sudo add-apt-repository -y ppa:wireshark-dev/stable
sudo DEBIAN_FRONTEND=noninteractive apt install -y tshark
sudo sysctl -w net.ipv4.ip_forward=1
pip install numpy matplotlib pandas
#Fixing Indigo
#Note: The reason it is not working locally is because Tensorflow uses AVX instructions. All computers do not support that computer architecture, but it seems that powder does.
pip install protobuf==3.17 --user

# Install Pantheon-tunnel
cd $BASE_DIR
git clone https://github.com/StanfordSNR/pantheon-tunnel.git
cd pantheon-tunnel/
./autogen.sh
./configure
make
sudo make install
cd ..
rm -Rf pantheon-tunnel/

# Install Pantheon
git clone https://github.com/Fadi-B/pantheon.git
cd pantheon

# Patch: remove the 3 second delay
#sed -i "s/time.sleep(self.run_first_setup_time)/time.sleep(0)/g" ./src/experiments/test.py

tools/fetch_submodules.sh
./src/experiments/setup.py --install-deps --schemes "$CC_SCHEMES"

#Fixing Copa Bug
diff -u $BASE_DIR/pantheon/third_party/genericCC/markoviancc.cc /local/repository/patches/markovian_update.cc > markov_patch.patch
patch $BASE_DIR/pantheon/third_party/genericCC/markoviancc.cc markov_patch.patch
rm markov_patch.patch

./src/experiments/setup.py --setup --schemes "$CC_SCHEMES"

echo "Done"
date
touch /local/ready