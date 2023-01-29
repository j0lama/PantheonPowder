#!/bin/bash

if [ -f "/local/ready" ]; then
    echo "Pantheon already installed."
    cd /pantheon
    src/experiments/setup.py --schemes "bbr copa cubic fillp fillp_sheep ledbat pcc pcc_experimental quic scream sprout taova vegas verus vivace webrtc"
    exit 1
fi

BASE_DIR="/local"

# Install dependencies
sudo apt update -y
sudo apt install -y python-yaml python-pip mahimahi texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra
sudo add-apt-repository -y ppa:wireshark-dev/stable
sudo DEBIAN_FRONTEND=noninteractive apt install -y tshark
sudo sysctl -w net.ipv4.ip_forward=1
pip install numpy matplotlib
#Fixing Indigo
#Note: The reason it is not working locally is because Tensorflow uses AVX instructions
#      All computers do not support that computer architecture, but it seems that powder does.
python -m pip install protobuf==3.17 --user

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
tools/fetch_submodules.sh
./src/experiments/setup.py --install-deps --schemes "bbr copa cubic fillp fillp_sheep ledbat pcc pcc_experimental quic scream sprout taova vegas verus vivace webrtc indigo"

#Fixing Copa Bug
diff -u $BASE_DIR/pantheon/third_party/genericCC/markoviancc.cc /local/repository/scripts/markovian_update.cc > markov_patch.patch
patch $BASE_DIR/pantheon/third_party/genericCC/markoviancc.cc markov_patch.patch
rm markov_patch.patch

./src/experiments/setup.py --setup --schemes "bbr copa cubic fillp fillp_sheep ledbat pcc pcc_experimental quic scream sprout taova vegas verus vivace webrtc indigo"

echo "Done"
date
touch /local/ready