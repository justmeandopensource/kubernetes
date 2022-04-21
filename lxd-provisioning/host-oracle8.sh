GRE=$1
LinuxFlavor=$2

./host-oracle8-firewalld.sh $LinuxFlavor
./host-oracle8-firewalld-check.sh $LinuxFlavor
# ./host-oracle8-modules.sh $GRE
# ./host-oracle8-mount.sh
./host-oracle8-storage.sh $GRE

