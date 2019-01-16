#!/bin/bash

POD_NAME=`kubectl get pod -n al-crashloop | grep monitor | cut -d' ' -f 1`
kubectl exec -it $POD_NAME -n al-crashloop /root/nginx-crashloop.sh 2>&1 > /dev/null
