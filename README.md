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
Выполнил сборку образов приложения:
```
cd ../../src/ui
bash docker_build.sh

cd ../post-py
bash docker_build.sh

cd ../comment
bash docker_build.sh
```
    Можно было проще - for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done

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













