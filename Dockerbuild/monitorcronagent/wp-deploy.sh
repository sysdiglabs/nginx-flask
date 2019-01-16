#!/bin/bash

curl -X POST -s https://${SDC_API_ENDPOINT}/api/events \
-H 'Content-Type: application/json; charset=UTF-8' \
-H 'Accept: application/json, text/javascript, */*; q=0.01' \
-H 'Authorization: Bearer '"${SDC_API_KEY}"'' \
--data-binary '{"event":{"name":"Jenkins - start wordpress deploy","description":"deploy","severity":'6',"tags":{"build":"89"}}}' --compressed

sleep 5s

kubectl set image deployment/wordpress wordpress=ltagliamonte/broken-wordpress:latest --namespace=wp-demo

sleep 5m

kubectl set image deployment/wordpress wordpress=wordpress:latest --namespace=wp-demo

sleep 5s

curl -X POST -s https://${SDC_API_ENDPOINT}/api/events \
-H 'Content-Type: application/json; charset=UTF-8' \
-H 'Accept: application/json, text/javascript, */*; q=0.01' \
-H 'Authorization: Bearer '"${SDC_API_KEY}"'' \
--data-binary '{"event":{"name":"Jenkins - roll-back deploy completed","description":"deploy","severity":'6',"tags":{"build":"88"}}}' --compressed

exit 0
