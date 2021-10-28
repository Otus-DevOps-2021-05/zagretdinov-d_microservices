# zagretdinov-d_microservices
zagretdinov-d microservices repository
## Kubernetes. Networks, Storages.
Поднимаю кластер kubernetes через terraform и разворачиваю приложение

![изображение](https://user-images.githubusercontent.com/85208391/139145755-de9a3d86-5d62-4570-b5fe-e02e7c4e0001.png)

![изображение](https://user-images.githubusercontent.com/85208391/139145776-41b4eaba-1265-41c0-ae6f-6886ef67956c.png)

Проверяю приложение:

![изображение](https://user-images.githubusercontent.com/85208391/139145843-fab8c5e0-c438-4fad-9130-0dc5f41fa72f.png)

## LoadBalancer
Настроим соответствующим образом Service UI и проверяю

![изображение](https://user-images.githubusercontent.com/85208391/139148196-fd20b2cc-b275-4e45-b20c-490bf79fc292.png)

![изображение](https://user-images.githubusercontent.com/85208391/139148223-d0ea76fe-3500-4b81-85d3-58c927d9c8c8.png)

Недостатки LoadBalancer

    Нельзя управлять с помощью http URI (L7-балансировщика)
    Используются только облачные балансировщики (AWS, GCP)
    Нет гибких правил работы с трафиком

## Ingress
Создадим Ingress для сервиса UI применяю конфиг и проверяю.

![изображение](https://user-images.githubusercontent.com/85208391/139148639-b4483169-3e2c-4e27-a0b9-21c423424522.png)

![изображение](https://user-images.githubusercontent.com/85208391/139148672-4b651ed0-603b-4fc4-858f-8fb926ff4b05.png)

![изображение](https://user-images.githubusercontent.com/85208391/139148690-2b7cc62b-0f08-4e56-a54f-391d52cc2624.png)

![изображение](https://user-images.githubusercontent.com/85208391/139148716-e2820f8f-b9d4-4c16-8582-28f305404f7b.png)

## Secret

Теперь давайте защитим наш сервис с помощью TLS Для начала вспомним IngressIP

![изображение](https://user-images.githubusercontent.com/85208391/139148963-67eeb6c1-ffa1-41fa-8fd8-b79fc2ec56c2.png)

## TLS TerminationTL

Теперь настроим Ingress на прием только HTTPS траффика, применяю, пересоздаю.
```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ui
  annotations:
    kubernetes.io/ingress.allow-http: "false"
spec:
  tls:
  - secretName: ui-ingress
  backend:
    serviceName: ui
    servicePort: 9292

$ kubectl apply -f ui-ingress.yml -n dev

$ kubectl delete ingress ui -n dev
$ kubectl apply -f ui-ingress.yml -n dev

```
Проверяю

![изображение](https://user-images.githubusercontent.com/85208391/139149508-ba3f7b86-082c-450b-994c-54b65760a14e.png)

## Задание со *

Создаваемый объект Secret в виде Kubernetes-манифеста описывается по ссылке
https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets

![изображение](https://user-images.githubusercontent.com/85208391/139170873-6000bb03-77a8-43b7-8ebf-ce082d5f2ca4.png)

![изображение](https://user-images.githubusercontent.com/85208391/139170899-7d6f8368-e234-4249-94d5-d037556a70ca.png)

## Хранилище для базы

Cоздаю диск PersitentVolume в ya.cloud

```
yc compute disk create \
 --name k8s \
 --zone ru-central1-a \
 --size 4 \
 --description "disk for k8s"
```
![изображение](https://user-images.githubusercontent.com/85208391/139171053-237c1a40-1bd5-43fe-8e17-e39053accef8.png)

![изображение](https://user-images.githubusercontent.com/85208391/139171192-381b9f8e-19d9-44ae-a193-7d2c5bb2c625.png)


Создаю и собираю необходимые файлы конфигурации.

![изображение](https://user-images.githubusercontent.com/85208391/139171612-14c41827-8cd6-4f39-92b8-38dc88895a5e.png)

![изображение](https://user-images.githubusercontent.com/85208391/139171637-52025d65-c644-44f9-91fd-5a56c949ef99.png)

![изображение](https://user-images.githubusercontent.com/85208391/139171649-94a7e250-3b0d-4f02-83b6-618a8eb4ba2e.png)

![изображение](https://user-images.githubusercontent.com/85208391/139171654-9956daf3-02d5-4647-934d-f3252540fef8.png)

