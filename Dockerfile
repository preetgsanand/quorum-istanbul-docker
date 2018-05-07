FROM ubuntu:16.04

# setting up requiered software
RUN apt-get -qq update && apt-get install build-essential unzip libdb-dev libleveldb-dev libsodium-dev wget git vim psmisc zlib1g-dev libtinfo-dev curl -y -qq

RUN wget -q https://dl.google.com/go/go1.9.3.linux-amd64.tar.gz && tar xfz go1.9.3.linux-amd64.tar.gz && mv go /usr/local/go && rm -f go1.9.3.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
RUN echo 'PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

RUN git clone https://github.com/jpmorganchase/quorum.git
RUN cd /quorum && make all
RUN cp -r /quorum/build/bin/. /usr/local/bin

# additional software
ADD https://github.com/ethereum/solidity/releases/download/v0.4.23/solc-static-linux /usr/local/bin/solc
ADD https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 /usr/local/bin/jq
RUN chmod +x /usr/local/bin/solc /usr/local/bin/jq

# setting up Constellation
RUN wget -q https://github.com/jpmorganchase/constellation/releases/download/v0.3.2/constellation-0.3.2-ubuntu1604.tar.xz && tar xfJ constellation-0.3.2-ubuntu1604.tar.xz && cp constellation-0.3.2-ubuntu1604/constellation-node /usr/local/bin && chmod 0755 /usr/local/bin/constellation-node && rm -rf constellation-0.3.2-ubuntu1604

#setting work dir
RUN mkdir istanbul-node
ADD genesis.json istanbul-node/genesis.json
ADD startNode.sh istanbul-node/startNode.sh
ADD nodekey istanbul-node/nodekey
ADD passwords.txt istanbul-node/passwords.txt

# running script
RUN chmod +x istanbul-node/startNode.sh
ENTRYPOINT ["istanbul-node/startNode.sh"]
