# zagretdinov-d_microservices
zagretdinov-d microservices repository

# Docker-образы Микросервисы
## Подготовка
Заранее были скачены готовые репозитории и распакованны.
Новая структура приложения.
Три компонента - post-py (написание постов), comment (комментарии), ui (веб-интерфейс) 
    • создаю докерфайлы для каждого компонента
    • post-py/dockerfile имеются небольшие изменения, иначе установка компонентов через pip проваливалась.
```
FROM python:3.6.14-alpine

WORKDIR /app

ADD requirements.txt /app

RUN apk --no-cache --update add build-base && \
    pip install -r /app/requirements.txt && \
    apk del build-base

ADD . /app

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]

```

### comment/dockerfile
```
FROM ruby:2.3-alpine

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/

RUN apk add --no-cache build-base \
    && gem install bundler -v 1.17.2 \
    && bundle install \
    && apk del build-base

ADD . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
```
### ui/dockerfile
```
FROM ruby:2.3-alpine

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/

RUN apk add --no-cache build-base \
    && gem install bundler -v 1.17.2 \
    && bundle install \
    && apk del build-base

ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
```

## Создание образов.

![изображение](https://user-images.githubusercontent.com/85208391/130621379-eb4591dc-8ebb-42b0-ad30-476a2564bba2.png)

### сборка образов с компонентами
```
ocker build -t zagretdinov/comment:2.0-alpine ./comment
docker build -t zagretdinov/ui:2.0-alpine ./ui
```
### post 1.0 работал некорректно, поэтому сразу заменен на 2.0

```
docker build -t zagretdinov/post:1.0 ./post-py
```

почему сборка ui началась со второго шага - потому что ui и comment создаются на базе ruby:2.3, и первый шаг у них одинаковый (установка build essential ) был выполнен при билде comment, и соответствующий промежуточный слой сохранился в системе.

## Запуск контейнеров

### Запуск микросервисов

создание специальной bridge-сети для приложения (для того, чтобы можно было использовать сетевые алиасы)

```
docker network create reddit
```

![изображение](https://user-images.githubusercontent.com/85208391/130627594-8690b6cc-4985-4b36-af5b-bd58a9defc6e.png)

запуск контейнеров с указанием алиасов

```
docker run -d --network=reddit \
--network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit \
--network-alias=post zagretdinov/post:1.0
docker run -d --network=reddit \
--network-alias=comment zagretdinov/comment:2.0-alpine
docker run -d --network=reddit \
-p 9292:9292 zagretdinov/ui:2.0-alpine
```
![изображение](https://user-images.githubusercontent.com/85208391/130627783-303a1ebd-92ab-4844-9c57-fb23118ada11.png)

Сетевые алиасы могут быть использованы для сетевых соединений, как доменные имена

- перейдя по адресу http://178.154.204.207:9292/, можно проверить работоспособность приложения

![изображение](https://user-images.githubusercontent.com/85208391/130629301-12e48765-c23b-4cba-8df5-c7951a9ba092.png)

## Задание со ⭐
```
docker kill $(docker ps -q)
```
Запуск с изменением сетевых алиасов
```
docker run -d --network=reddit --network-alias=post_db1 --network-alias=comment_db1 -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post1 -e POST_DATABASE_HOST='post_db1' zagretdinov/post:1.0
docker run -d --network=reddit --network-alias=comment1 -e COMMENT_DATABASE_HOST='comment_db1' zagretdinov/comment:2.0-alpine
docker run -d --network=reddit -e POST_SERVICE_HOST='post1' -e COMMENT_SERVICE_HOST='comment1' -p 9292:9292 zagretdinov/ui:2.0-alpine
```

### Уменьшение размеров образов 
размер образа UI можно уменьшить, изменив dockerfile

```
FROM ruby:2.3-alpine
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile* $APP_HOME/

RUN apk add --no-cache build-base \
    && gem install bundler -v 1.17.2 \
    && bundle install \
    && apk del build-base
COPY . $APP_HOME
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
CMD ["puma"]
```
![изображение](https://user-images.githubusercontent.com/85208391/130629750-e1d21768-cf7e-4ec7-aa97-5fb88b86ed0d.png)


- Помещаю в один RUN как можно больше действий по установке.
- замена ADD на COPY, указывать определенную версию пакета, и удаление списков apt-get после установки

## Присоединение Volume для хранения БД постов.
удалив-стерев (kill) контейнеры и создав их заново, теряются все старые посты

### Создание docker volume
```
docker volume create reddit_db
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post zagretdinov/post:1.0
docker run -d --network=reddit --network-alias=comment zagretdinov/comment:2.0-alpine
docker run -d --network=reddit -p 9292:9292 zagretdinov/ui:2.0-alpine
```
![изображение](https://user-images.githubusercontent.com/85208391/130632780-a3a2e6d9-1cf4-4574-be3d-f3e79aa13615.png)
