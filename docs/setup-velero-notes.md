### Running minio container
```
docker pull minio/minio
docker run --name minio -p 9000:9000 -v data:/data minio/minio server /data
```

### Grab access and secret key
/data/.minio.sys/config/config.json
```
docker exec -it minio cat /data/.minio.sys/config/config.json | egrep "(access|secret)Key"
```
Change access key and secret key from the Minio dashboard.

### Download Velero 1.0.0 Release
```
wget https://github.com/heptio/velero/releases/download/v1.0.0/velero-v1.0.0-linux-amd64.tar.gz
tar zxf velero-v1.0.0-linux-amd64.tar.gz
sudo mv velero-v1.0.0-linux-amd64/velero /usr/local/bin/
rm -rf velero*

```

### Create credentials file (Needed for velero initialization)
```
cat <<EOF>> minio.credentials
[default]
aws_access_key_id=minio
aws_secret_access_key=minio123
EOF
```

### Install Velero in the Kubernetes Cluster
```
velero install \
   --provider aws \
   --bucket kubedemo \
   --secret-file ./minio.credentials \
   --backup-location-config region=minio,s3ForcePathStyle=true,s3Url=http://<ip>:9000
```

### Enable tab completion for preferred shell
```
source <(velero completion zsh)
```
