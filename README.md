# kubernetes
Kubernetes playground
# installation metalLB
1) telecharger manifest depuis le site officiel
https://metallb.universe.tf/installation/

kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml

2)ajouter une configMap pour définir la plage IP external
```
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: k8s-master-ip-space
      protocol: layer2
      addresses:
      - 172.23.0.100-172.23.0.250    
```
# install and configure ingress controller with nginx Bare Metal


## install nginx controller
ressources:

namespace
service account
cluster Role
cluster Role Binding
ConfigMap
Secret
Daemonset

1)copy repo from github


```bash
▶ git clone https://github.com/nginxinc/kubernetes-ingress.git
▶ cd kubernetes-ingress
▶ cd deployments

```
## 1. Create a Namespace, a SA, the Default Secret, the Customization Config Map, and Custom Resource Definitions

1. Create a namespace and a service account for the Ingress controller:
    ```
    kubectl apply -f common/ns-and-sa.yaml
    ```

1. Create a secret with a TLS certificate and a key for the default server in NGINX:
    ```
    $ kubectl apply -f common/default-server-secret.yaml
    ```

    **Note**: The default server returns the Not Found page with the 404 status code for all requests for domains for which there are no Ingress rules defined. For testing purposes we include a self-signed certificate and key that we generated. However, we recommend that you use your own certificate and key.

1. Create a config map for customizing NGINX configuration (read more about customization [here](configmap-and-annotations.md)):

    ```
    $ kubectl apply -f common/nginx-config.yaml
    ```

1. (Optional) To use the [VirtualServer and VirtualServerRoute](virtualserver-and-virtualserverroute.md) resources, create the corresponding resource definitions:
    ```
    $ kubectl apply -f common/custom-resource-definitions.yaml
    ```
    Note: in Step 3, make sure the Ingress controller starts with the `-enable-custom-resources` [command-line argument](cli-arguments.md).

## 2. Configure RBAC

If RBAC is enabled in your cluster, create a cluster role and bind it to the service account, created in Step 1:
```
$ kubectl apply -f rbac/rbac.yaml
```

**Note**: To perform this step you must be a cluster admin. Follow the documentation of your Kubernetes platform to configure the admin access. For GKE, see the [Role-Based Access Control](https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control) doc.

## 3. Deploy the Ingress Controller

We include two options for deploying the Ingress controller:
* *Deployment*. Use a Deployment if you plan to dynamically change the number of Ingress controller replicas.
* *DaemonSet*. Use a DaemonSet for deploying the Ingress controller on every node or a subset of nodes.

### 3.1 Create a DaemonSet

For NGINX, run:
```
$ kubectl apply -f daemon-set/nginx-ingress.yaml
```
Kubernetes will create an Ingress controller pod on every node of the cluster. Read [this doc](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) to learn how to run the Ingress controller on a subset of nodes, instead of every node of the cluster.

### 3.2 Check that the Ingress Controller is Running

Run the following command to make sure that the Ingress controller pods are running:
```
$ kubectl get pods --namespace=nginx-ingress
```
## 4. Deploy pods for testing your ingress Controller

### first deployment with home page

```
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: nginx-deploy-main
spec:
  replicas: 1
  selector:
    matchLabels:
      run: nginx-main
  template:
    metadata:
      labels:
        run: nginx-main
    spec:
      containers:
      - image: nginx
        name: nginx
```


### second deployment an pod with page green

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: nginx-deploy-green
spec:
  replicas: 1
  selector:
    matchLabels:
      run: nginx-green
  template:
    metadata:
      labels:
        run: nginx-green
    spec:
      volumes:
      - name: webdata
        emptyDir: {}
      initContainers:
      - name: web-content
        image: busybox
        volumeMounts:
        - name: webdata
          mountPath: "/webdata"
        command: ["/bin/sh", "-c", 'echo "<h1>I am <font color=green>GREEN</font></h1>" > /webdata/index.html']
      containers:
      - image: nginx
        name: nginx
        volumeMounts:
        - name: webdata
          mountPath: "/usr/share/nginx/html"
```

### Third deployment an pod with page blue

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: nginx-deploy-blue
spec:
  replicas: 1
  selector:
    matchLabels:
      run: nginx-blue
  template:
    metadata:
      labels:
        run: nginx-blue
    spec:
      volumes:
      - name: webdata
        emptyDir: {}
      initContainers:
      - name: web-content
        image: busybox
        volumeMounts:
        - name: webdata
          mountPath: "/webdata"
        command: ["/bin/sh", "-c", 'echo "<h1>I am <font color=blue>BLUE</font></h1>" > /webdata/index.html']
      containers:
      - image: nginx
        name: nginx
        volumeMounts:
        - name: webdata
          mountPath: "/usr/share/nginx/html"
```

### 5. Create service to expose yours pods (by default clusterIP if you don't specify the type)

```
kubectl expose deploy nginx-deploy-main --port 80
kubectl expose deploy nginx-deploy-blue --port 80
kubectl expose deploy nginx-deploy-green --port 80
```

### 6.add ingress ressource

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-resource-2
spec:
  rules:
  - host: nginx.example.com
    http:
      paths:
      - backend:
          serviceName: nginx-deploy-main
          servicePort: 80
  - host: blue.nginx.example.com
    http:
      paths:
      - backend:
          serviceName: nginx-deploy-blue
          servicePort: 80
  - host: green.nginx.example.com
    http:
      paths:
      - backend:
          serviceName: nginx-deploy-green
          servicePort: 80
```

# install storageClass nfs avec une helm nfs-client-provisioner

1)installer nfs server
2)create partage /srv/nfs/kubedata
3)dans chaque serveur du cluster k8s installé nfs-utils

```
yum install nfs-utils
```
4)sur le cluster kubernetes lancer la creation d'une storageclass avec la charte helm

```
helm install stable/nfs-client-provisioner --set nfs.server=172.23.0.1 --set nfs.path=/srv/nfs/kubedata
```
nfs.server=l'adresse du serveur phisique nfs
nfs.path=le dossier partagé ou export nfs

# installation prometheus avec grafana en utilisant helm
install helm in your cluster
install chart prometheus
```
helm inspect stable/prometheus > /tmp/prom.values
```
change type off service on NodePort
vim /tmp/prom.values
```
    externalIPs: []

    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    servicePort: 80
    nodePort: 31114
    sessionAffinity: None
    type: NodePort
```
```
helm install --values /tmp/prom.values --name myprom1 stable/prometheus
```
or 

```
helm install --name myprom1 --set server.service.type=NodePort --set server.service.nodePort=32222  stable/prometheus 
```

### si votre service n'est pas créer en mode NodePort il faut supprimer le service et le recrier manuellement

```
 #kubectl delete svc myprom1-prometheus-server
 #kubectl expose deployment myprom1-prometheus-server --type=NodePort --port=80 --target-port=9090
```
## installé grafana 
1) methode :
```
helm install stable/grafana --name mygrafana --set persistence.enabled=true --set persistence.accessModes={ReadWriteOnce} --set persistence.size=8Gi --set service.type=NodePort --set service.nodePort=32221
```
user: admin 
password nous pouvons le récuperé depuis le secret du chart

```
kubectl get secret --namespace default mygrafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
mygrafana: nom du chart

2) méthode
helm inspect stable/grafana > /tmp/grafana.values

vim /tmp/grafana.values
```
service:
  type: NodePort
  port: 80
  nodePort: 32211
  targetPort: 3000
    # targetPort: 4181 To be used with a proxy extraContainer
  annotations: {}
  labels: {}
  portName: service
```
```
kubectl expose deployment grafana1 --type=NodePort --port=80 --target-port=3000
```
user: admin 
password nous pouvons le récuperé depuis le secret du chart

```
kubectl get secret --namespace default mygrafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
mygrafana: nom du chart
## install rancher on your cluster
1)run container runcher on your local machine

```
sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher
```
2)execute this manifests on your cluster k8S
```
curl --insecure -sfL https://localhost/v3/import/qv476x7mtw2kw2fp6fz452glcmknsgwj6cvx7jqxt9mrv2qts2mwdd.yaml | kubectl apply -f -
```

