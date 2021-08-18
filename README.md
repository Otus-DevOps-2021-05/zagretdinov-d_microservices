# zagretdinov-d_microservices
zagretdinov-d microservices repository

## Технология контейнеризации. Введение в Docker
Создал новую ветку docker-2 в вашем microservices репозитории в организации DevOps 2020-05.

![изображение](https://user-images.githubusercontent.com/85208391/129976546-2789013b-7d6f-44ea-83ac-c15e77389707.png)

Настроена интеграция с slacke, travis-ci, по аналогии infa.

![изображение](https://user-images.githubusercontent.com/85208391/129976741-864d96e7-b227-485f-b829-9da91b84684f.png)

![изображение](https://user-images.githubusercontent.com/85208391/129976787-1ab3b9d9-3bda-45ad-97fa-fe5ef83cea4a.png)

Интеграцию с travis провел в форкнутом уже в своем репозитории.

![изображение](https://user-images.githubusercontent.com/85208391/129976968-95ad8073-9ade-4267-8e63-47e62ffd7a92.png)

Создаю директорию dockermonolith

Устанавливаю Docker.
 
 ![изображение](https://user-images.githubusercontent.com/85208391/129979430-ea9659b2-741c-43f8-8efa-b5f17a0964fd.png)

Представленна вся информация о системе
 ![изображение](https://user-images.githubusercontent.com/85208391/129979447-4fcccd2e-e8ef-4980-9f11-d82bf5d09ec6.png)

 ![изображение](https://user-images.githubusercontent.com/85208391/129979487-5d847cde-14d3-48dd-94f7-7201ab2f674a.png)

 ![изображение](https://user-images.githubusercontent.com/85208391/129979583-04212810-a4e0-4e95-8f85-40f82b279f33.png)

![изображение](https://user-images.githubusercontent.com/85208391/129979623-c3047ade-d6d9-454a-a454-5637e3cc88e3.png)

 ![изображение](https://user-images.githubusercontent.com/85208391/129979650-6bbcb580-cce2-4802-a264-0af27e590dd4.png)

![изображение](https://user-images.githubusercontent.com/85208391/129979668-6221d157-865b-473b-9955-a066ff4d3a5d.png)

## Docker start & attach
start запускает  остановленный (уже созданный) контейнер 
attach подсоединяет терминалк созданному контейнеру
 
 ![изображение](https://user-images.githubusercontent.com/85208391/129979861-a255b56c-7ab7-4f6f-8203-ce41e5ea7382.png)

![изображение](https://user-images.githubusercontent.com/85208391/129979886-f7cdc50b-58eb-42b9-9415-e891456a0790.png)

 ![изображение](https://user-images.githubusercontent.com/85208391/129979896-8da9dc30-88dc-49ad-9515-b6f8ea067a51.png)

## Docker exec

![изображение](https://user-images.githubusercontent.com/85208391/129979953-fc8ffc6b-7167-45ef-bcef-2d8a24f23772.png)

![изображение](https://user-images.githubusercontent.com/85208391/129980224-6a8afba3-1b16-48f4-8e96-c059fe3ef22e.png)

## Задание со* 
Сравните вывод двух следующих команд

Команда docker inspect получает метаданные верхнего слоя контейнера и образа. 
Отличие контейнер от образа, контейнер коммитится и он становится образом, это означает 
что его верхний слой, тот, куда можно было записывать что-либо, станет read only.
в образе видно данные хешируются, где можно наблюдать в начале вывода.  
 
 ![изображение](https://user-images.githubusercontent.com/85208391/129980362-e9f1cf74-340e-4f17-ac9c-08b7c8a69a1a.png)

![изображение](https://user-images.githubusercontent.com/85208391/129980389-7fcfdd84-fb4d-448b-8609-40e8cf4dc681.png)

 
 
 
 
 
 Прежде чем установливать и начать работу с Docker группу пользователей  

``` sudo groupadd docker ```

и добавлю своего плользователя.

``` sudo usermod -aG docker $USER ```
чтоб не вполнять перезагрузку пк 

```newgrp docker```



















