#!/bin/bash

for i in `seq 1 7`;
do
	kubectl scale deployment nginx --namespace=al-crashloop --replicas=3
	sleep 40
	kubectl scale deployment nginx --namespace=al-crashloop --replicas=0
	sleep 10
done

exit 0
