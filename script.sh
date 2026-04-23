#!/bin/bash

if [[ -z "${NAMESPACE:-}" ]]; then
    echo >&2 "Must set \$NAMESPACE"
    exit 1
fi

set -euo pipefail

for pv in $(kubectl -n "$NAMESPACE" get pv -o custom-columns=NAME:.metadata.name,CLAIM:.spec.claimRef.name | grep '\(clickhouse-data\)\|keeper' | cut -d' ' -f 1); do
    reclaim_policy="$(kubectl -n "$NAMESPACE" get pv "$pv" -o 'go-template={{.spec.persistentVolumeReclaimPolicy}}')"
    if [[ "$reclaim_policy" != "Retain" ]]; then
        echo >&2 "Patching $pv from $reclaim_policy to Retain"
        if [[ -n "${DRY_RUN:-}" ]]; then
            echo "DRY RUN ::: " kubectl -n "$NAMESPACE" patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
        else
            kubectl -n "$NAMESPACE" patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
        fi
    else
        echo >&2 "$pv reclaim policy is already Retain"
    fi
done
