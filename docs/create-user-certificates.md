# User certificate creation
Related Youtube video here: 

[[ Kube 68 ] Kubernetes RBAC Demo | Creating Users and Roles](https://www.youtube.com/watch?v=U67OwM-e9rQ&lc=Ugx2qEQhNPOGFn5PmRF4AaABAg)

Generating private key for John (john.key)
```
$ openssl genrsa -out john.key 2048
```

Generating certificate signing request (john.csr)
```
$ openssl req -new -key john.key -out john.csr -subj "/CN=john/O=finance"
```

Copy kubernetes ca certificate and key from the master node kmaster
>If you used my vagrant provisioning scripts, the root password for all the nodes is "kubeadmin"
```
$ scp root@kmaster:/etc/kubernetes/pki/ca.{crt,key} .
```

Sign the certificate using certificate authority
```
$ openssl x509 -req -in john.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out john.crt -days 365
```
