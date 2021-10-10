# zagretdinov-d_microservices
zagretdinov-d microservices repository
## Введение в kubernetes

Создал директорию kubernetes в корне проекта. Внутри нее создал директорию reddit. Создал 4 манифеста.

```
post-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: post-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: post
  template:
    metadata:
      name: post
      labels:
        app: post
    spec:
      containers:
        - image: zagretdinov/post
          name: post

ui-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ui-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ui
  template:
    metadata:
      name: ui
      labels:
        app: ui
    spec:
      containers:
        - image: zagretdinov/ui
          name: ui

comment-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: comment-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: comment
  template:
    metadata:
      name: comment
      labels:
        app: comment
    spec:
      containers:
        - image: fresk/comment
          name: comment
mongo-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongo-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: mongo
    spec:
      containers:
        - image: mongo:3.2
          name: mongonetes
```
## Поднял 2 VM использовал ОСubuntu 20 на каждую выполнил

одна VM node1 вторая node2
```
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install docker-ce=5:19.03.15~3-0~ubuntu-focal docker-ce-cli=5:19.03.15~3-0~ubuntu-focal containerd.io kubelet=1.19.14-00 kubeadm=1.19.15-00 kubectl=1.19.15-00
```

На node1 выполнил
```
kubeadm init --apiserver-cert-extra-sans=<PUBLIC_IP> --apiserver-advertise-address=0.0.0.0 --control-plane-endpoint=<PUBLIC_IP> --pod-network-cidr=10.244.0.0/16
```

Поднял кластер k8s с помощью kubeadm

На node2
```
sudo kubeadm join 178.154.240.189:6443 --token ujd6g5.oidc0y6b7brcztnh \
    --discovery-token-ca-cert-hash sha256:f673a31834cec6ef588ac1c70393d7b8ec8f92392bc865d5fa89cee0d32e02fd
```

Создаю конфиг файл для пользователя на мастер ноде:
```
mkdir $HOME/.kube/
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $USER $HOME/.kube/config
```
В результате проверяю node

![изображение](https://user-images.githubusercontent.com/85208391/136695202-9b39c12e-2690-4610-8989-f1c0f1aef0bd.png)

ноды находятся в статусе NotReady







