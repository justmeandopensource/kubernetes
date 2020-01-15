# Deploying Spinnaker in a Kubernetes cluster

### Pre-requisites
Kubernetes cluster with atleast **4 cores** and **8GB memory**


#### Start Halyard Container

```
mkdir ~/.hal
docker run --name halyard -v ~/.hal:/home/spinnaker/.hal -v ~/.kube/config:/home/spinnaker/.kube/config -d gcr.io/spinnaker-marketplace/halyard:stable
```

Get a shell into Halyard container
```
docker exec -it halyard bash
```

### Below commands are to be run inside the halyard container

Check if you can run kubectl commands
```
kubectl cluster-info
```

#### Set Kubernetes as the cloud provider
```
hal config provider kubernetes enable
```

#### Add a kubernetes account
```
hal config provider kubernetes account add my-k8s --provider-version v2 --context $(kubectl config current-context)
```

#### Enable artifacts
```
hal config features edit --artifacts true
```

#### Choose where to install Spinnaker
```
hal config deploy edit --type distributed --account-name my-k8s
```

### Below command needs to be run on your local machine where you have helm binary
#### Install minio in kubernetes cluster
```
kubectl create ns spinnaker
helm install minio --namespace spinnaker --set accessKey="myaccesskey" --set secretKey="mysecretkey" --set persistence.enabled=false stable/minio
```
The above helm install command will only work if you are running Helm v3+. If you are using Helm v2, use this command instead
```
helm install --name minio --namespace spinnaker --set accessKey="myaccesskey" --set secretKey="mysecretkey" --set persistence.enabled=false stable/minio
```

### Back inside the halyard container
#### For minio, disable s3 versioning
```
mkdir ~/.hal/default/profiles
echo "spinnaker.s3.versioning: false" > ~/.hal/default/profiles/front50-local.yml
```
#### Set the storage type to minio/s3
```
hal config storage s3 edit --endpoint http://minio:9000 --access-key-id "myaccesskey" --secret-access-key "mysecretkey"
hal config storage s3 edit --path-style-access true
hal config storage edit --type s3
```

#### Choose spinnaker version to install
```
hal version list
hal config version edit --version <desired-version>
```

#### All Done! Deploy Spinnaker in Kubernetes Cluster
```
hal deploy apply
```

#### Change the service type to either Load Balancer or NodePort
```
kubectl -n spinnaker edit svc spin-deck
kubectl -n spinnaker edit svc spin-gate
```

#### Update config and redeploy
```
hal config security ui edit --override-base-url "http://<LoadBalancerIP>:9000"
hal config security api edit --override-base-url "http://<LoadBalancerIP>:8084"
hal deploy apply
```
*If you used NodePort*
```

hal config security ui edit --override-base-url "http://<worker-node-ip>:<nodePort>"
hal config security api edit --override-base-url "http://worker-node-ip>:<nodePort>"
hal deploy apply
```
