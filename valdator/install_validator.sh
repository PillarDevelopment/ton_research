#!/usr/bin/
apt-get -y install make
apt-get -y install cmake
apt-get -y install g++
apt-get -y install clang
apt-get -y install zlib1g-dev
apt-get -y install libreadline-dev
apt-get -y install libmicrohttpd-dev
apt-get -y install texlive-full
apt-get -y install ccache
apt-get -y install doxygen
apt-get -y install build-essential gperf
apt-get -y install libz-dev libssl-dev libgflags-dev
apt-get -y install git

cd /home/validator

git clone --recursive https://github.com/ton-blockchain/ton.git git_ton
git submodule update --init --recursive

export CXX=/usr/bin/clang++
update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-6.0 100

rm -rf /srv/ton/
rm -rf build_ton
mkdir build_ton
mkdir -p /srv/ton/db

cd build_ton

#build ton
cmake -DCMAKE_BUILD_TYPE=Release ../git_ton
cmake --build .


cp crypto/fift /usr/bin/fift
cp crypto/func /usr/bin/func
cp lite-client/lite-client /usr/bin/lite-client
cp validator-engine/validator-engine /usr/bin/validator-engine
cp validator-engine-console/validator-engine-console /usr/bin/validator-engine-console

chmod 755 /usr/bin/fift
chmod 755 /usr/bin/func
chmod 755 /usr/bin/lite-client
chmod 755 /usr/bin/validator-engine
chmod 755 /usr/bin/validator-engine-console

cd /srv/ton

rm -rf /srv/ton/ton-global.config.json
wget https://test.ton.org/ton-global.config.json

#start very first time to create /srv/ton/db/config.json file
validator-engine -C /srv/ton/ton-global.config.json --db /srv/ton/db/ -l /srv/ton/log

cd /home/validator/build_ton/utils

./generate-random-id -m keys -n server > server.txt
./generate-random-id -m keys -n client > client.txt
./generate-random-id -m keys -n liteserver > liteserver.txt

PRVKEY_SERVER=`cat server.txt | awk '{print $1;}'`
PUBKEY_SERVER=`cat server.txt | awk '{print $2;}'`

PRVKEY_CLIENT=`cat client.txt | awk '{print $1;}'`
PUBKEY_CLIENT=`cat client.txt | awk '{print $2;}'`

PRVKEY_LITESERVER=`cat liteserver.txt | awk '{print $1;}'`
PUBKEY_LITESERVER=`cat liteserver.txt | awk '{print $2;}'`

cp server /srv/ton/db/keyring/$PRVKEY_SERVER
cp client /srv/ton/db/keyring/$PRVKEY_CLIENT
cp liteserver /srv/ton/db/keyring/$PRVKEY_LITESERVER


liteserver='"liteservers" : [ { "@type" : "engine.liteServer",  "id" : "'$PUBKEY_LITESERVER'", "port" : 8383 }'

#echo $liteserver

control='"control" : [{ "@type" : "engine.controlInterface", "id" : "'$PUBKEY_SERVER'", "port" : 8282,  "allowed" : [ { "@type" : "engine.controlProcess", "id" : "'$PUBKEY_CLIENT'", "permissions" : 15  } ]  }'

#echo $control

sed -i "s|\"liteservers\" \: \[|$liteserver|g" /srv/ton/db/config.json
sed -i "s|\"control\" \: \[|$control|g" /srv/ton/db/config.json

chown -R validator:validator /srv/ton
chown -R validator:validator /home/validator/build_ton
chown -R validator:validator /home/validator/git_ton

echo
echo "Start validator from systemctl"
echo "example (mind IP): validator-engine -C /srv/ton/ton-global.config.json --db /srv/ton/db/ -l /srv/ton/log --ip *.*.*.*:8081 -t 32"
echo "test validator console: build/utils/validator-engine -C /srv/ton/ton-global.config.json --db /srv/ton/db/ -l /srv/ton/log --ip *.*.*.*:8081 -t 32"
echo "test lite-server: build/utils/lite-client -a *.*.*.*:8383 -p liteserver.pub"


# подключиться к cli validator cli

# тестирование отправки запросов

confluence - validator setup - https://ammer.atlassian.net/wiki/spaces/TECO/pages/120291329/Validator+Setup
