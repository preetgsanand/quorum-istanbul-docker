#!/bin/bash

cd istanbul-node

echo "[*] Initializing Constellation Node"

mkdir -p qdata/{c,logs}

echo "[*] Generating Constellation Node Credentials"

echo "" | constellation-node --generatekeys=qdata/c/tm

echo "[*] Starting Constellation Node"

constellation-node --workdir=qdata/c --socket=tm.ipc --url=http://$(hostname -I | xargs):10000/ --privatekeys=tm.key --publickeys=tm.pub --verbosity=4 --port=10000 $OTHER_NODES_PARAM >> qdata/logs/constellation.log 2>&1 &

sleep 3

echo "[*] Initializing Geth Node"

mkdir -p qdata/dd/{keystore,geth}

if [ "$OTHER_NODES_PARAM" == "" ];
	then
	mv nodekey qdata/dd/geth
fi

geth --datadir qdata/dd init genesis.json

echo "[*] Creating Geth Node Credentials"

geth --datadir qdata/dd --password passwords.txt account new

echo "[*] Starting Geth Node"

ARGS="--nodiscover --syncmode full --mine --rpc --rpcaddr $(hostname -I | xargs) --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul"

PRIVATE_CONFIG=./qdata/c/tm.ipc nohup geth --datadir qdata/dd $ARGS --rpcport 22000 --port 21000 2>>qdata/logs/geth.log &


while sleep 360; do
  ps aux |grep constellation |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep geth |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done