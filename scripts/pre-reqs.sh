#!/bin/bash
TKG_CMD=${TKG_CMD:-tkg}
VALUES_YAML=${1:-values.yaml}

# Get a starting config file
if [ -f generated/tkg-template-config.yaml ]; then
  echo Template config exists, skipping generation
else
  $TKG_CMD --config generated/tkg-template-config.yaml get mc 2>&1 > /dev/null
fi

# Generate Management
if [ -f generated/tkg-config-mgmt.yaml ]; then
  echo "Management config exists, skipping generation"
else
  ytt -f $VALUES_YAML -f generated/tkg-template-config.yaml -f overlays/tkg-config-core.yaml -f overlays/tkg-config-mgmt-cluster.yaml --ignore-unknown-comments > generated/tkg-config-mgmt.yaml
fi

# Create Management cluster
TKG_MC_JSON=$($TKG_CMD --config generated/tkg-config-mgmt.yaml get mc -o json)
if [[ "$TKG_MC_JSON" != "" && $(echo $TKG_MC_JSON | jq length) -ge 1 ]]; then
  echo "Detected management cluster(s) already present"
else
  $TKG_CMD --config generated/tkg-config-mgmt.yaml init --infrastructure=vsphere --plan dev mgmt 
fi

if [ -f generated/tkg-config-worker.yaml ]; then
  echo "Worker config exists, skipping generation"
else
  ytt -f $VALUES_YAML -f generated/tkg-config-mgmt.yaml -f overlays/tkg-config-core.yaml -f overlays/tkg-config-guest-cluster.yaml --ignore-unknown-comments > generated/tkg-config-worker.yaml
fi

# Create demo cluster
TKG_CLUSTER_JSON=$($TKG_CMD --config generated/tkg-config-worker.yaml get clusters -o json)
if [[ "$TKG_CLUSTER_JSON" != "" && $(echo $TKG_CLUSTER_JSON | jq length) -ge 1 ]]; then
  echo "Detected worker cluster already present"
else
  $TKG_CMD --config generated/tkg-config-worker.yaml create cluster -p dev -w 3 demo
fi

