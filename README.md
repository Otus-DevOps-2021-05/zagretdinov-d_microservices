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

Опишите создаваемый объект Secret в виде Kubernetes-манифеста





