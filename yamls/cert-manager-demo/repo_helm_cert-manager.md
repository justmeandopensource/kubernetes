https://hub.helm.sh/charts/jetstack/cert-manager
cert-manager
cert-manager is a Kubernetes addon to automate the management and issuance of TLS certificates from various issuing sources.

It will ensure certificates are valid and up to date periodically, and attempt to renew certificates at an appropriate time before expiry.

Prerequisites
Kubernetes 1.7+
Installing the Chart
Full installation instructions, including details on how to configure extra functionality in cert-manager can be found in the getting started docs.

To install the chart with the release name my-release:

## IMPORTANT: you MUST install the cert-manager CRDs **before** installing the
## cert-manager Helm chart
$ kubectl apply --validate=false\
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml

## If you are installing on openshift :
$ oc create \
    -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml

## Add the Jetstack Helm repository
$ helm repo add jetstack https://charts.jetstack.io


## Install the cert-manager helm chart
$ helm install --name my-release --namespace cert-manager jetstack/cert-manager
In order to begin issuing certificates, you will need to set up a ClusterIssuer or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).

More information on the different types of issuers and how to configure them can be found in our documentation:

https://docs.cert-manager.io/en/latest/tasks/issuers/index.html

For information on how to configure cert-manager to automatically provision Certificates for Ingress resources, take a look at the ingress-shim documentation:

https://docs.cert-manager.io/en/latest/tasks/issuing-certificates/ingress-shim.html

Tip: List all releases using helm list

Upgrading the Chart
Special considerations may be required when upgrading the Helm chart, and these are documented in our full upgrading guide. Please check here before perform upgrades!

Uninstalling the Chart
To uninstall/delete the my-release deployment:

$ helm delete my-release
The command removes all the Kubernetes components associated with the chart and deletes the release.

