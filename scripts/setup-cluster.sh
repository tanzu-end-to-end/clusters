#!/bin/bash
TKG_CMD=${TKG_CMD:-tkg}
VALUES_YAML=${1:-values.yaml}

METALLB_TAG=v0.9.5

export KUBECONFIG=generated/kubeconfig-worker

if [ -f $KUBECONFIG ]; then
  echo Skipping credential retrieve
else
  $TKG_CMD --config generated/tkg-config-worker.yaml get credentials demo --export-file $KUBECONFIG
fi

# Default Storage class
kubectl apply -f <(ytt -f $VALUES_YAML -f overlays/default-storage-class.yaml)

# METALLB
kapp deploy -a metallb -f https://raw.githubusercontent.com/metallb/metallb/$METALLB_TAG/manifests/namespace.yaml \
  -f https://raw.githubusercontent.com/metallb/metallb/$METALLB_TAG/manifests/metallb.yaml \
  -f <(ytt -f values.yaml -f overlays/metallb)

# CertManager
kapp deploy -a cert-manager -f extensions/tkg-extensions-v1.1.0/cert-manager/ -f <(ytt -f values.yaml -f overlays/cert-manager)

# External DNS
helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create ns tanzu-system-ingress
kapp deploy -a external-dns --into-ns tanzu-system-ingress \
  -f <(helm template external-dns bitnami/external-dns -n tanzu-system-ingress -f <(ytt -f values.yaml -f overlays/external-dns/values.yaml)) -f <(ytt -f values.yaml -f overlays/external-dns/gcp-credentials-secret.yaml)

# Contour (we use AWS because we have MetalLB installed.  The AWS scripts use LoadBalancers)
kapp deploy -a contour \
  -f <(ytt -f values.yaml \
      -f extensions/tkg-extensions-v1.1.0/ingress/contour/aws \
      -f overlays/contour \
      --allow-symlink-destination=extensions/tkg-extensions-v1.1.0/ingress/contour/vsphere \
      --ignore-unknown-comments)