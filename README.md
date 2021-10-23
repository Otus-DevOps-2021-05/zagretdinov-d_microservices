# zagretdinov-d_microservices
zagretdinov-d microservices repository
## Kubernetes. Запусккластера и приложения. Модель безопасности

Устанавливаю kubectl и minikube

https://kubernetes.io/docs/tasks/tools/install-kubectl/
https://kubernetes.io/docs/tasks/tools/install-minikube/

Проверяю:
![изображение](https://user-images.githubusercontent.com/85208391/138560696-7e4b8d30-db68-44d9-80dd-a8b4dd92d339.png)

Разворачиваем Kubernetes локально для работы Minikube использовал virtualbox.
```
minikube start —driver=virtualbox
```
![изображение](https://user-images.githubusercontent.com/85208391/138561113-201d70a2-174d-4c3c-9bcf-f2ee7f435a3b.png)

## Запуск приложения

![изображение](https://user-images.githubusercontent.com/85208391/138561951-a5bd84fd-a82d-49a1-96f0-7e25c8440016.png)

![изображение](https://user-images.githubusercontent.com/85208391/138561959-4fef9bd9-05d3-4ad6-814b-a88473cb4f30.png)

```
kubectl get componentstatuses
kubectl cluster-info
```
![изображение](https://user-images.githubusercontent.com/85208391/138562108-895a6bc6-cc7a-43f8-8e6d-07b2c25e4016.png)

![изображение](https://user-images.githubusercontent.com/85208391/138562110-70702fc9-08ad-4b4b-846e-635a2d1d280b.png)

![изображение](https://user-images.githubusercontent.com/85208391/138562468-6aa83e7c-a392-4ccf-9a58-02b3e65c1e77.png)

![изображение](https://user-images.githubusercontent.com/85208391/138562472-b6b86797-b41b-4b22-b043-d90a0b9c2775.png)

![изображение](https://user-images.githubusercontent.com/85208391/138562500-0766b998-c69c-4671-a2ed-729c451fb672.png)




























