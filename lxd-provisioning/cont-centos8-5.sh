n=1
Cmd0=1
while [ $Cmd0 -ne 0 ] && [ $n -le 5 ]
do
        dnf upgrade -y --refresh
        Cmd0=`echo $?`
        n=$((n+1))
        sleep 5
done
dnf install -y epel-release
dnf install -y sshpass
systemctl enable kubelet.service
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all --kubernetes-version=v1.23.0-beta.0 | tee kubeadm_init.log
echo "Sleeping 30 seconds while kubernetes master starts running ..."
sleep 30
cat kubeadm_init.log | grep -A1 join | grep -A1 token > joincluster.sh
chmod +x joincluster.sh
export KUBECONFIG=/etc/kubernetes/admin.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo "Sleeping 30 seconds while weavenet starts running ..."
echo ''
kubectl get pods --all-namespaces -o wide
sleep 30
echo ''
kubectl get pods --all-namespaces -o wide
sleep 30
echo ''
kubectl get pods --all-namespaces -o wide
sleep 30
sshpass -p root scp    -o CheckHostIP=no -o StrictHostKeyChecking=no -p /root/joincluster.sh root@10.207.39.5:/root/.
sshpass -p root scp    -o CheckHostIP=no -o StrictHostKeyChecking=no -p /root/joincluster.sh root@10.207.39.6:/root/.
echo ''
sshpass -p root ssh -t -o CheckHostIP=no -o StrictHostKeyChecking=no root@10.207.39.5 "/root/joincluster.sh"
sleep 10
echo ''
sshpass -p root ssh -t -o CheckHostIP=no -o StrictHostKeyChecking=no root@10.207.39.6 "/root/joincluster.sh"

sleep 30

function CheckWeaveNetRunning {
	kubectl get -A pods -o wide | grep weave | grep -c Running
}
WeaveNetRunning=$(CheckWeaveNetRunning)

n=1
while [ $WeaveNetRunning -lt 3 ] && [ $n -le 5 ]
do
	sleep 15
	WeaveNetRunning=$(CheckWeaveNetRunning)
	n=$((n+1))
done

if [ $WeaveNetRunning -eq 0 ]
then
	kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
fi

n=1
while [ $WeaveNetRunning -lt 3 ] && [ $n -le 5 ]
do
	sleep 15
	WeaveNetRunning=$(CheckWeaveNetRunning)
	n=$((n+1))
done

