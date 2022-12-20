#!/bin/bash

if [ -d "/local/repository/scripts/pantheon" ];
then
    echo "Pantheon already installed."
    cd /local/repository/scripts/pantheon
    src/experiments/setup.py --schemes "bbr copa cubic fillp fillp_sheep ledbat pcc pcc_experimental quic scream sprout taova vegas verus vivace webrtc"
fi

sudo apt update -y
sudo apt install -y python-yaml
sudo add-apt-repository -y ppa:wireshark-dev/stable
sudo DEBIAN_FRONTEND=noninteractive apt install -y tshark
sudo sysctl -w net.ipv4.ip_forward=1

# Install mahimahi
sudo add-apt-repository -y ppa:keithw/mahimahi
sudo apt -y update
sudo apt install -y mahimahi

#Dealing with Pantheon
cd /local/repository/scripts/
git clone https://github.com/StanfordSNR/pantheon.git
cd pantheon
tools/fetch_submodules.sh
src/experiments/setup.py --install-deps --schemes "bbr copa cubic fillp fillp_sheep ledbat pcc pcc_experimental quic scream sprout taova vegas verus vivace webrtc"
src/experiments/setup.py --setup --schemes "bbr copa cubic fillp fillp_sheep ledbat pcc pcc_experimental quic scream sprout taova vegas verus vivace webrtc"

echo "Done"
date