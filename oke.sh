#!/bin/bash
echo "OKE_SERVERZ = $OKE_SERVERZ, token = $OKE_TOKEN"
kubectl apply -f $1 --server=$OKE_SERVERZ --token=$OKE_TOKEN --insecure-skip-tls-verify=true
