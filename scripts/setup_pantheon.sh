#!/bin/bash

#!/bin/bash

DIR=/tmp/downloads
if [ -d "/local/repository/pantheon" ];
then
    echo "Pantheon already installed."
fi

sudo apt update -y
sudo apt install -y python-yaml
sudo add-apt-repository -y ppa:wireshark-dev/stable
sudo DEBIAN_FRONTEND=noninteractive apt install -y tshark

sudo sysctl -w net.ipv4.ip_forward=1

#Dealing with Pantheon
git clone https://github.com/StanfordSNR/pantheon.git
cd /local/repository/pantheon
tools/fetch_submodules.sh
src/experiments/setup.py --install-deps --schemes "bbr copa cubic fillp fillp_sheep ledbat pcc pcc_experimental quic scream sprout taova vegas verus vivace webrtc"
src/experiments/setup.py --setup --schemes "bbr copa cubic fillp fillp_sheep ledbat pcc pcc_experimental quic scream sprout taova vegas verus vivace webrtc"