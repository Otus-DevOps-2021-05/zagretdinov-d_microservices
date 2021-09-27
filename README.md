# zagretdinov-d_microservices
zagretdinov-d microservices repository
## Введение в мониторинг. Системы мониторинга.
Создаю Docker хост и настраиваю локальное окружение:
```
yc compute instance create \
  --name docker-host1 \
  --memory=4 \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/zagretdinov.pub
```
```
docker-machine create \
  --driver generic \
  --generic-ip-address=84.201.174.97 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/zagretdinov \
  docker-host
```
eval $(docker-machine env docker-host1)

## Запуск Prometheus
заливаю готовый образ с DockerHub:
![изображение](https://user-images.githubusercontent.com/85208391/133867912-13efc461-e465-441a-b83b-defed41e7877.png)

![изображение](https://user-images.githubusercontent.com/85208391/133868060-93eebf8c-bdfa-4406-be0c-9216f9e94c1a.png)

перехожу по адресу http://84.201.174.97:9090
![изображение](https://user-images.githubusercontent.com/85208391/133867996-fe9a0d3a-d09c-415f-8b3e-72093530ec67.png)

## Targets

Targets (цели) - представляют собой системы или процессы, за которыми следит Prometheus. Prometheus является pull системой, поэтому он постоянно делает HTTP запросы на имеющиеся у него адреса (endpoints). Посмотрим текущий список целей - Status -> Targets

![изображение](https://user-images.githubusercontent.com/85208391/133868141-3c663f3c-237c-4e99-9aeb-c9b73c8a298e.png)

Так выглядит информация собранная Prometheus.
![изображение](https://user-images.githubusercontent.com/85208391/133868419-3a0847eb-58cb-42d2-ba8b-b5ec345657ae.png)

Остановил контейнер:
```
docker stop prometheus
```
Перенес docker-monolith и docker-compose в папку docker. Создал папку monitoring. В папке monitoring создал prometheus. В ней создал Dockerfile:

```
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/

Создал файл prometheus.yml:

global:
  scrape_interval: '5s'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets:
        - 'localhost:9090'

  - job_name: 'ui'
    static_configs:
      - targets:
        - 'ui:9292'

  - job_name: 'comment'
    static_configs:
      - targets:
        - 'comment:9292'
```
Собрал образ:
```
cd monitoring/prometheus
export USER_NAME=fresk
docker build -t $USER_NAME/prometheus .
```
![изображение](https://user-images.githubusercontent.com/85208391/133907819-0243d5de-c789-487c-8e74-fafcf399109c.png)


И выполнил сборку образов приложения:

```
cd ../../src/ui
bash docker_build.sh

cd ../post-py
bash docker_build.sh

cd ../comment
bash docker_build.sh
```
Выполнил сразу из корня репозиторияе - for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done

![изображение](https://user-images.githubusercontent.com/85208391/133907849-6d71b038-f2fe-4425-a697-e5e8281b77fb.png)
![изображение](https://user-images.githubusercontent.com/85208391/133908049-dff4bc90-0da3-4620-b29b-40916a862332.png)


## Поднимаю Prometheus совместно с микросервисами.

Добавил прометеус в docker-compose:
```
services:
...
  prometheus:
    image: ${USERNAME}/prometheus
    ports:
      - '9090:9090'
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d'

volumes:
  prometheus_data:
```
Удалил build директивы из docker_compose.yml

Добавил всем сервисам сеть:
```
networks:
  - prometheus_net
```
В .env поправил версии образов на latest.

Запустил docker-compose:

cd docker
docker-compose up -d

![изображение](https://user-images.githubusercontent.com/85208391/133908101-90873652-a0c3-459a-b1fe-34f21cde6f7c.png)

![изображение](https://user-images.githubusercontent.com/85208391/133908107-18bc43b8-5676-4a0f-a18b-a9f78dba31d0.png)

Проверяю работоспособность приложения.

![изображение](https://user-images.githubusercontent.com/85208391/133908119-e0ecd5d1-0643-4caf-9144-45e5fa34905c.png)

## Мониторинг состояния микросервисов
Просмотрю список enpoint-ов.

![изображение](https://user-images.githubusercontent.com/85208391/133908227-9572e29c-e106-49e1-8b33-434e68069efa.png)

## Healtcheck
представляют собой проверки того, что наш сервис здорови работает в ожидаемом режиме
Вбил в интерфейсе прометеуса ui_health, нажал execute, получил:

![изображение](https://user-images.githubusercontent.com/85208391/133908708-ff1b0a62-2dc4-4706-8777-705be60238ea.png)

Остановливаю ```post docker-compose stop post```
В итоге изменилась метрика на значение ноль.

![изображение](https://user-images.githubusercontent.com/85208391/133909156-fc883b90-2a54-41d9-bfb8-5a2131642ee1.png)

## Поиск проблемы
Помимо статуса сервиса, мы также собираем статусы сервисов, от которых он зависит. Названия метрик, значения которых соответствует данным статусам, имеет формат ui_health_.


В строке ui_health_comment_availability, увидел, что статус не менялся. 
Проверил ui_health_post_availability - статус изменился на 0.
Проблема нужно стартануть контейнер.
```docker-compose start post```

## Сбор метрик хоста

Определил еще один сервис в docker/docker-compose.yml файле.
```
node-exporter:
  image: prom/node-exporter:v0.15.2
  networks:
    - prometheus_net
  user: root
  volumes:
    - /proc:/host/proc:ro
    - /sys:/host/sys:ro
    - /:/rootfs:ro
  command:
    - '--path.procfs=/host/proc'
    - '--path.sysfs=/host/sys'
    - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'
```
Добавил в конфиг прометеуса:
```
- job_name: 'node'
  static_configs:
    - targets:
      - 'node-exporter:9100'
```
Собрал новый образ прометеуса:
```
cd monitoring/prometheus
docker build -t $USER_NAME/prometheus .
```
![изображение](https://user-images.githubusercontent.com/85208391/133909347-167b85b0-7b87-4d70-9975-d5e9bdd72649.png)

Пересоздал сервисы:
```
cd ../../docker
docker-compose down
docker-compose up -d
```
![изображение](https://user-images.githubusercontent.com/85208391/133909357-57722d20-c82b-4e7e-b092-69986a12f33f.png)
![изображение](https://user-images.githubusercontent.com/85208391/133909363-dee9c256-9dbf-4c5f-87d5-118fa59f7050.png)


Смотрю проверяю список endpoint-ов

![изображение](https://user-images.githubusercontent.com/85208391/133909403-6998ee68-8994-482d-b2d2-7b689e77c953.png)

появилась node.


В списке endpoint-ов(Status -> Targets) прометеуса появился еще один endpoint.

Получил информацию об использовании ЦПУ - node_load1

Проверил нагрузку:

    зашел на машинку docker-machine ssh docker-host
    увеличил нагрузку yes > /dev/null
    мониторинг отобразил выросшую нагрузку

![изображение](https://user-images.githubusercontent.com/85208391/133909586-070ed425-5689-4d21-9f77-8bd733e040ed.png)

![изображение](https://user-images.githubusercontent.com/85208391/133909593-2965c1b8-db61-45bc-8b58-6646f826dc6c.png)



## Задание *

![изображение](https://user-images.githubusercontent.com/85208391/133909599-5a536181-2c06-47fb-80d1-76165e5f7e9e.png)

## Завершение работы

Запушил образы на docker-hub:
```
docker push $USER_NAME/ui
docker push $USER_NAME/comment
docker push $USER_NAME/post
docker push $USER_NAME/prometheus 
```

- https://hub.docker.com/repository/docker/zagretdinov/prometheus
- https://hub.docker.com/repository/docker/zagretdinov/post
- https://hub.docker.com/repository/docker/zagretdinov/ui
- https://hub.docker.com/repository/docker/zagretdinov/comment

