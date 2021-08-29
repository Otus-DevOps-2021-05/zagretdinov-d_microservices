# zagretdinov-d_microservices
zagretdinov-d microservices repository

# Docker: сети, docker-compose
## Подготовка
Создаю новую ветку docker-4
Подключаюсь к ранее созданному docker host’у.
eval $(docker-machine env docker-host)
![изображение](https://user-images.githubusercontent.com/85208391/131217349-ac12633b-fd5d-47b3-bbaf-a2ae05681eec.png)

# Работа с сетью
## None network driver
![изображение](https://user-images.githubusercontent.com/85208391/131217380-88a12b03-ba49-4ec4-9d48-7952f9050bd7.png)

Один сетевой интерфейс - Loopback. Сетевой стек самого контейнера работает (ping localhost), но без возможности контактировать с внешним миром.

Вывод команды docker-machine ssh docker-host ifconfig.

![изображение](https://user-images.githubusercontent.com/85208391/131217404-201cfcb8-c1d3-42d7-9f88-4e9ee81eabaa.png)

Выполнил на докер хосте, чтобы видеть список namespace:
![изображение](https://user-images.githubusercontent.com/85208391/131217435-afef2d70-0bac-4426-bfce-80bd039e2a84.png)


Выполнил на докер хосте, чтобы видеть список namespace:

## Host network driver

![изображение](https://user-images.githubusercontent.com/85208391/131251332-e26b99d2-cadc-43fb-8d5c-cd4948a175e6.png)

![изображение](https://user-images.githubusercontent.com/85208391/131251339-7478a88e-4476-49c4-ad9a-97687ba7b4be.png)

## Bridge network driver

Создал bridge-сеть

```
docker run -d --network=reddit mongo:latest
docker run -d --network=reddit zagretdinov/post:1.0
docker run -d --network=reddit zagretdinov/comment:2.0-alpine
docker run -d --network=reddit -p 9292:9292 zagretdinov/ui:2.0-alpine
```










