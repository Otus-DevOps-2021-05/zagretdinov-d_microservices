# zagretdinov-d_microservices
zagretdinov-d microservices repository
## Логирование и распределенная трассировка.
### Подготовка окружения
```
yc compute instance create \
  --name logging \
  --memory=4 \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/zagretdinov.pub

docker-machine create \
  --driver generic \
  --generic-ip-address=62.84.115.246 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/zagretdinov \
  logging
```
Устананавливаю docker-compose на docker хосте
```
docker-machine ssh logging
sudo apt install docker-compose
eval $(docker-machine env logging)
```
Сборка новых образов:
```
export USER_NAME='username'

cd ./src/ui && bash docker_build.sh && docker push $USER_NAME/ui:logging
cd ../post-py && bash docker_build.sh && docker push $USER_NAME/post:logging
cd ../comment && bash docker_build.sh && docker push $USER_NAME/comment:logging
```
## Логирование Docker контейнеров
## Elastic Stack
Рассмотрим пример системы централизованного логирования на примере Elastic стека (ранее известного как ELK): который включает в себя 3 осовных компонента:

    ElasticSearch (TSDB и поисковый движок для хранения данных)
    Logstash (для агрегации и трансформации данных)
    Kibana (для визуализации)
Для аггрегации логов вместо Logstash будем использовать Fluentd, получим еще одно популярное сочетание этих инструментов - EFK.

Fluentd - инструмент, который может использоваться для отправки, аггрегации и преобразования лог-сообщений. Fluentd будем использовать для аггрегации (сбора в одном месте) и парсинга логов сервисов нашего приложения.

В директории logging/fluentd создаем Dockerfile:
```
FROM fluent/fluentd:v0.12
RUN gem install fluent-plugin-elasticsearch --no-rdoc --no-ri --version 1.9.5
RUN gem install fluent-plugin-grok-parser --no-rdoc --no-ri --version 1.0.0
ADD fluent.conf /fluentd/etc
```
Для фаила ``` logging/fluentd/fluent.conf ```
```
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<match *.**>
  @type copy
  <store>
    @type elasticsearch
    host elasticsearch
    port 9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    type_name access_log
    tag_key @log_name
    flush_interval 1s
  </store>
  <store>
    @type stdout
  </store>
</match>

```
Соберем docker image для fluentd:
```
cd logging/fluentd
docker build -t $USER_NAME/fluentd .
```

## Структурированные логи

Логи должны иметь заданную (единую) структуру и содержать необходимую для нормальной эксплуатации данного сервиса информацию о его работе.

Лог-сообщения также должны иметь понятный для выбранной системы логирования формат, чтобы избежать ненужной траты ресурсов на преобразование данных в нужный вид.

Для запуска подготовленных контейнеров настроим docker/docker-compose.yml на теги :logging и запустим сервисы:

```
cd docker && docker-compose -f docker-compose.yml up -d
```
Посмотреть логи.
```
docker-compose logs -f post
```

Добавил драйвер для fluentd в docker-compose.yml
```
  post:
    ...
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.post
  ```
  
Поднял инфраструктуру централизованной системы логирования и перезапустил сервисы приложения

docker-compose -f docker-compose-logging.yml up -d
docker-compose down
docker-compose up -d

Kibana - инструмент для визуализации и анализа логов от компании Elastic.

## Добавление фильтра во Fluentd для сервиса post

Добавил logging/fluentd/fluent.conf:
```
<source>
 @type forward
 port 24224
 bind 0.0.0.0
</source>

<filter service.post>
 @type parser
 format json
 key_name log
</filter>

<match *.**>
 @type copy

...
```

## Неструктурированные логи

Неструктурированные логи отличаются отсутствием четкой структуры данных. Также часто бывает, что формат лог-сообщений не подстроен под систему централизованного логирования, что существенно увеличивает затраты вычислительных и временных ресурсов на обработку данных и выделение нужной информации.

На примере сервиса ui мы рассмотрим пример логов с неудобным форматом сообщений.

Добавил в docker-compose.yml лог-драйвер для ui:
```
  ui:
    ...
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.ui
```
Перезапустил приложение:
```
docker-compose stop ui
docker-compose rm ui
docker-compose up -d
```
Добавил в fluent.conf парсинг такого лога с помощью регулярных выражений:
```
<filter service.ui>
  @type parser
  format /\[(?<time>[^\]]*)\]  (?<level>\S+) (?<user>\S+)[\W]*service=(?<service>\S+)[\W]*event=(?<event>\S+)[\W]*(?:path=(?<path>\S+)[\W]*)?request_id=(?<request_id>\S+)[\W]*(?:remote_addr=(?<remote_addr>\S+)[\W]*)?(?:method= (?<method>\S+)[\W]*)?(?:response_status=(?<response_status>\S+)[\W]*)?(?:message='(?<message>[^\']*)[\W]*)?/
  key_name log
</filter>
```
Пересобрал образ и перезапустил контейнер:
```
cd ../logging/fluentd
docker build -t $USER_NAME/fluentd .
cd ../../docker
docker-compose -f docker-compose-logging.yml up -d
````
Созданные регулярки могут иметь ошибки, их сложно менять и невозможно читать. Для облегчения задачи парсинга вместо стандартных регулярок можно использовать grok-шаблоны. По-сути grok’и - это именованные шаблоны регулярных выражений (очень похоже на функции). Можно использовать готовый regexp, просто сославшись на него как на функцию docker/fluentd/fluent.conf
```
...
<filter service.ui>
  @type parser
  key_name log
  format grok
  grok_pattern %{RUBY_LOGGER}
</filter>

<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  key_name message
  reserve_data true
</filter>
...
```
Распределенный трейсинг

Добавил zipkin в docker-compose-logging.yml
```
zipkin:
    image: openzipkin/zipkin
    ports:
      - "9411:9411"
```
Добавил для всех сервисов в docker-compose.yml:
```
environment:
  - ZIPKIN_ENABLED=${ZIPKIN_ENABLED}
```
Добавил в .env
```
ZIPKIN_ENABLED=true
```
Добавил сети приложения в docker-compose-logging.yml
```
  zipkin:
    ...
    networks:
      - front_net
      - back_net
...
networks:
  back_net:
  front_net:
```
Пересоздал сервисы:
```
docker-compose -f docker-compose-logging.yml -f docker-compose.yml down
docker-compose -f docker-compose-logging.yml -f docker-compose.yml up -d
```

Строго выполнялось все по шагово согласно задания.
Работа приложения.
![изображение](https://user-images.githubusercontent.com/85208391/136380884-b9616398-0b41-4d77-b492-a2067b4d9e50.png)

Kibana слушает на порту 5601
![изображение](https://user-images.githubusercontent.com/85208391/136386128-89ba8f2e-b549-46c8-9081-423314b6041f.png)

Зашел в веб-интерфейс zipkin по порту 9411

![изображение](https://user-images.githubusercontent.com/85208391/136387486-a0a46609-7ce2-4ed1-a685-05821c1a930f.png)

# * Траблшутинг UI-экспириенса
Собераю образы со сломанным кодом и пересобираю инфраструктуру.
Запсускаю zipkin и демонстрирую не исправность.
Вот даная задержка.
![изображение](https://user-images.githubusercontent.com/85208391/136389545-b023cc7c-abd7-4465-bb19-a4eb30b39e6a.png)

![изображение](https://user-images.githubusercontent.com/85208391/136389603-13b25456-0c28-45c2-ba30-361c463eea89.png)

а вот так код выглядит после исправления.
![изображение](https://user-images.githubusercontent.com/85208391/136389845-3e9f4009-aabc-43f9-9836-7015e10cdc4e.png)

