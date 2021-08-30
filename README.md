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

Запускаю проект в двух bridge сетях, чтобы ui не имел доступа к db.

Остановил контейнеры:

``` docker kill $(docker ps -q) ```

Создадаю docker-сети

```
docker network create back_net --subnet=10.0.2.0/24 
docker network create front_net --subnet=10.0.1.0/24
```

![изображение](https://user-images.githubusercontent.com/85208391/131252469-920a868d-d59a-4e70-a4b2-8fb09e6efca5.png)

```
docker run -d --network=front_net -p 9292:9292 --name ui zagretdinov/ui:2.0-alpine
docker run -d --network=back_net --name comment zagretdinov/comment:2.0-alpine
docker run -d --network=back_net --name post zagretdinov/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest
```
При открытие приложения в браузере получил ошибку

![изображение](https://user-images.githubusercontent.com/85208391/131252486-d85cfe75-87df-4d2e-b46f-ccb4691c70b3.png)

Docker при инициализации контейнера может подключить к нему только одну сеть. При этом контейнеры из соседних сетей не будут доступны как в DNS, так и для взаимодействия по сети.

Поэтому нужно поместить контейнеры post и comment в обе сети.

Подключил контейнеры ко второй сети:

![изображение](https://user-images.githubusercontent.com/85208391/131252590-0d02e16d-b1e3-49e9-b745-c3e376140c74.png)

теперь все работает

![изображение](https://user-images.githubusercontent.com/85208391/131252595-1cff0d54-fda8-4265-a795-ce16a22343bb.png)

Посмотрим, как выглядит сетевой стек Linux в текущий момент.
Зашел на докер-хост и установил bridge-utils:

![изображение](https://user-images.githubusercontent.com/85208391/131252794-fdece3ac-7417-4f9a-9593-e0054221ed9c.png)

и выполняю согласно порядка заданий:
```
sudo apt-get update && sudo apt-get install bridge-utils
```
![изображение](https://user-images.githubusercontent.com/85208391/131252814-bfab155b-8fe9-4230-a288-8f5384e94018.png)

![изображение](https://user-images.githubusercontent.com/85208391/131252904-13a779bf-5c13-4e8c-b47a-d0831ac2d4a7.png)

![изображение](https://user-images.githubusercontent.com/85208391/131252907-44f819a1-5b56-42b8-8806-029c5ad27a0c.png)

на iptables
``` sudo iptables -nL -t nat ```

Нас интересует цепочка POSTROUTING

![изображение](https://user-images.githubusercontent.com/85208391/131252924-874e1298-7e36-4290-a194-e2a0a9c02988.png)

В ходе работы была необходимость публикации порта контейнера UI (9292) для доступа к нему снаружи. Посмотрим, что Docker при этом сделал в iptables:

Строчка DNAT.
![изображение](https://user-images.githubusercontent.com/85208391/131252968-47d7a5b4-e5af-4425-97f8-32840481e1b4.png)

запущен docker-proxy.
![изображение](https://user-images.githubusercontent.com/85208391/131252980-b3f08a01-2a82-4c6d-8c7d-117910b418ed.png)

## Docker-compose

Проблемы:
    • Одно приложение состоит из множества контейнеров/сервисов 
    • Один контейнер зависит от другого 
    • Порядок запуска имеет значение 
    • docker build/run/create … (долго и много) 
# docker-compose - отдельная утилита, позволяет декларативно описывать докер-инфраструктуры в yaml и управлять многоконтейнерными приложениями.

Создал src/docker-compose.yml:

```
version: '3.3'
services:
  post_db:
    image: mongo:3.2
    volumes:
      - post_db:/data/db
    networks:
      - reddit
  ui:
    build: ./ui
    image: ${USERNAME}/ui:2.0
    ports:
      - 9292:9292/tcp
    networks:
      - reddit
  post:
    build: ./post-py
    image: ${USERNAME}/post:1.0
    networks:
      - reddit
  comment:
    build: ./comment
    image: ${USERNAME}/comment:2.0
    networks:
      - reddit
volumes:
  post_db:
networks:
  reddit:
```
Останавливаю 
```
docker kill $(docker ps -q)
```
Экспортировал переменную USERNAME:

``` export USERNAME=fresk ```

Запустил контейнеры:

``` docker-compose up -d ```


проверил список контейнеров:

![изображение](https://user-images.githubusercontent.com/85208391/131254653-18853ff0-7995-4dd5-9cd8-41bd190cede8.png)

убедился, что проект работает.
