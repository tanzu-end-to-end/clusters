#!/bin/bash
VALUES_YAML=${1:-values.yaml}

EDUKATES_TAG=20.12.03.1

export KUBECONFIG=generated/kubeconfig-worker

kapp deploy -a edukates \
  -f <(kubectl apply -k "github.com/eduk8s/eduk8s?ref=$EDUKATES_TAG" --dry-run=client -o yaml | \
       ytt -f- -f values.yaml -f overlays/edukates --ignore-unknown-comments)
