# Cluster setup scripts
Scripts to setup a TKGm management and application cluster for the End to End Workshop

## Pre-reqs
You will need to install the following tools:
* kapp
* ytt
* TKG CLI (v1.1.x)
* Helm
* kubectl


A network with a DHCP server to which to connect the cluster node VMs that Tanzu Kubernetes Grid deploys is required!

These scripts assume you have already followed the [pre-reqs for TKG](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.1/vmware-tanzu-kubernetes-grid-11/GUID-install-tkg-vsphere.html#vsphere-permissions), and have [setup a storage policy](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.2/vmware-tanzu-kubernetes-grid-12/GUID-tanzu-k8s-clusters-storage.html#create-policy) to use for your default storage class.

Additionally, you need to setup a Route53 zone to host the domain for your workshop ev

## Values file
You will need to create a copy of the `values-example.yaml` file and save it as `values.yaml` in the root of the project to capture the settings you want to use for your environment.

## Setup
The setup is divided into three scripts:
* `pre-reqs.sh` - Creates the Management and Application clusters.
* `setup-cluster.sh` - Setup the default storage class, install MetalLB (software LB on vSphere), Cert-manager (talks to Let's Encrypt to make trusted certs), External-DNS (manage Route53), and Contour Ingress (L7 Ingress).
* `setup-edukates.sh` - Installs and configures the Edukates operator with the proper Ingress domain, and TLS cert.