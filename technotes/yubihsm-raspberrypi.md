# yubihsm-raspberrypi

## Description
The YubiHSM2 hardware security module can be used to generate ed25519 and secp256k1 public/private keypairs suitable for generating andau addresses and signatures. Generating these keypairs with the Raspberry Pi Zero provides additional security, as the Pi Zero has no Bluetooth, Wi-Fi, or Ethernet connectivity vulnerable to potential eavesdropping. These instructions describe how to build the Yubico yubico-connector HTTP server (https://github.com/Yubico/yubihsm-connector) and the Yubico Python library (https://github.com/Yubico/python-yubihsm) on the Pi Zero, and simple example Python applications are provided.

## Build Environment
For testing purposes, these instructions can also be used on the Raspberry Pi 3, which builds them much faster. The Pi Zero tools must be built on the Pi Zero itself due to its older processor architecture.

A Pi Zero W is a suitable build platform for the Pi Zero, and provides a more convenient environment. The build.sh script can be easily copied to and run on the Pi Zero W and the microSD card produced run on the Pi Zero.

### Raspbian Installation
1. Format a microSD card of at least 4GB capacity with a single FAT32 partition and a Master Boot Record.
2. Using Etcher or a similar tool, install the Raspbian Lite system image (2018-11-13-raspbian-stretch-lite.img) on that card.
3. Boot the Pi Zero or Pi Zero W from that microSD card.

The default keyboard setting is for the UK and may need to be changed for your system. On a Pi Zero W, connect to a Wi-Fi AP and enable the ssh server.

### Preparation - update apt repos, install git
```
# log in via SSH to 
sudo apt-get update
sudo apt-get install git --yes
git init
```

### Install golang and gb
```
curl -o go1.11.4.linux-armv6l.tar.gz https://dl.google.com/go/go1.11.4.linux-armv6l.tar.gz
sudo tar -C /usr/local -xzf go1.11.4.linux-armv6l.tar.gz
mkdir -p ~/go/bin
echo PATH=/usr/local/go/bin:~/go/bin:\$PATH >> .profile
source .profile

go get -u github.com/constabulary/gb/...
curl https://pre-commit.com/install-local.py | python -
source .profile
```

### libusb
```
sudo apt-get install libusb-1.0-0-dev  --yes
sudo ldconfig
```
### Build the yubihsm-connector
```

git clone https://github.com/Yubico/yubihsm-connector.git ~/yubihsm-connector
cd yubihsm-connector
pre-commit install
make
cd ~
```
### Establish udev rules for the yubihsm-connector
```
cat > 10-yubihsm.rules << EOF
# This udev file should be used with udev 188 and newer
SUBSYSTEM=="usb", MODE="0666"
ACTION!="add|change", GOTO="yubihsm2_connector_end"
# Yubico YubiHSM2
# The OWNER attribute here has to match the uid of the process running the Connector
SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0030", OWNER="yubihsm-connector", MODE="0666"
LABEL="yubihsm2_connector_end”
EOF
sudo cp 10-yubihsm.rules /etc/udev/rules.d
sudo udevadm control --reload-rules
```
### OpenSSL
The OpenSSL build takes about five hours on the Pi Zero. Much of the time is spent building and installing the documentation, but there doesn't seem to be an option to omit it.
```
git clone https://github.com/openssl/openssl openssl-3.0.0-dev
cd openssl-3.0.0-dev
./config
make
sudo make install
cd ~
```
### PIP
```
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python get-pip.py
sudo apt-get install python-dev --yes
sudo apt-get install libffi-dev
```
### Yubico Python library
```
sudo pip install yubihsm[http]
```
### Start the connector
The correct udev rules should eliminate the need to run the connector as root, but I haven't been able to get that to work properly
```
sudo yubihsm-connector/bin/yubihsm-connector &
```