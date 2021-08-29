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
При открытии приложения получил ошибку

![изображение](https://user-images.githubusercontent.com/85208391/131251774-c447a422-ac99-4db3-b2e4-48ac66a63665.png)

Сервисы ссылаются друг на друга по dns именам, прописанным в ENV-переменных (см Dockerfile). В текущей инсталляции встроенный DNS docker не знает ничего об этих именах.
Проблема решается присвоения контейнерам имен или сетевых алиасов при старте:
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post zagretdinov/post:1.0
docker run -d --network=reddit --network-alias=comment  zagretdinov/comment:2.0-alpine
docker run -d --network=reddit -p 9292:9292 zagretdinov/ui:2.0-alpine
```

![изображение](https://user-images.githubusercontent.com/85208391/131252180-c4dd1e54-aa95-43cc-b507-45577d31cc13.png)

Ошибка ушла

![изображение](https://user-images.githubusercontent.com/85208391/131252188-23f8383b-9151-42c0-97c4-e75cf6473500.png)




