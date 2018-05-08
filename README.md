# Steps


## 1. Build docker image

` docker build -t quorum_node . `

## 2. Run the bootnode

` docker run -d --name bootnode quorum_node`


## 3. Run consecutive nodes

` docker run -d -e OTHER_NODES_PARAM=--othernodes=http://{ip_of_bootnode_docker}:10000/ --name quorum_node{i} quorum_node`
* Additionally you can specify port mapping using -p e.g. -p 8545:22000

## 4. Add consecutive nodes to the network
* Adding to the Quorum Network
	* `docker exec -it quorum_node{i} bash`
	* `geth attach istanbul-node/qdata/dd/geth.ipc`
	* Find the enode address of the node by issuing `admin.nodeInfo.enode`
	* Replace `[::]` with the ip address of the docker
	* Exit from the docker bash console
	* Connect to the bootnode js console using the previous steps
	* Add the quorum_node{i} to the bootnode peers `admin.addPeer({enode_address_of_quorum_node})`
	* Both the nodes must appear as a peer to each other

* Adding to the Istanbul Validators
	* Go the quorum_node{i} js console using the previous steps 
	* Copy `eth.coinbase` of quorum_node{i}. This is the validators address of the node which needs to be proposed by other nodes
	* Go to the bootnode js console
	* Propose the addition of the quorum_node{i} to the validator list `istanbul.propose({coinbase_of_quorum_node{i}},true)`

Note : A new validator will only be added if 1/2 or more pre-existing nodes in the network propose its addition. So if a network has 3 nodes already, than atleast 2 nodes in the network must propose the addition of the new node.
