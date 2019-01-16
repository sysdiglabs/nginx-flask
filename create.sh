#!/bin/sh

cat <<- 'EOF' > "flask-deployment.yaml"
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: flask
  labels:
    name: flask-deployment
    app: nginx-crashloop
spec:
  replicas: 2
  selector:
    matchLabels:
     name: flask
     role: app
     app: nginx-crashloop
  template:
    spec:
      containers:
        - name: flask
          image: mateobur/flask
    metadata:
      labels:
        name: flask
        role: app
        app: nginx-crashloop
EOF

cat <<- 'EOF' > "nginx-deployment.yaml"
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: nginx
  labels:
    name: nginx-deployment
    app: nginx-crashloop
spec:
  replicas: 0
  selector:
    matchLabels:
     name: nginx
     role: app
     app: nginx-crashloop
  template:
    spec:
      containers:
        - name: nginx
          image: nginx
          volumeMounts:
          - name: "config"
            mountPath: "/etc/nginx/nginx.conf"
            subPath: "nginx.conf"
      volumes:
        - name: "config"
          configMap:
            name: "nginxconfig"
    metadata:
      labels:
        name: nginx
        role: app
        app: nginx-crashloop
EOF


cat <<- 'EOF' > "monitorcronagent.yaml"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: monitorcronagent-account
  namespace: al-crashloop
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: monitorcronagent-cluster-role
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
  - nonResourceURLs: ["*"]
    verbs: ["*"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: monitorcronagent-cluster-role-binding
subjects:
  - kind: ServiceAccount
    name: monitorcronagent-account
    namespace: al-crashloop
roleRef:
  kind: ClusterRole
  name: monitorcronagent-cluster-role
  apiGroup: rbac.authorization.k8s.io
---
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: monitorcronagent
  namespace: al-crashloop
  labels:
    app: monitorcronagent
spec:
  replicas: 1
  selector:
    matchLabels:
     app: monitorcronagent
  template:
    spec:
      serviceAccountName: monitorcronagent-account
      containers:
        - name: monitorcronagent
          image: mateobur/alcrashmonitor
    metadata:
      labels:
        app: monitorcronagent
EOF

kubectl create namespace al-crashloop
kubectl create --namespace=al-crashloop configmap nginxconfig --from-file nginx.conf
kubectl create --namespace=al-crashloop -f flask-deployment.yaml
kubectl create --namespace=al-crashloop -f nginx-deployment.yaml
kubectl create --namespace=al-crashloop -f monitorcronagent.yaml
rm flask-deployment.yaml nginx-deployment.yaml
