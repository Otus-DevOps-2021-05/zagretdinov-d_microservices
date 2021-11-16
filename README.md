# zagretdinov-d_microservices
zagretdinov-d microservices repository]

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

 ## Docker kill & stop
kill сразу посылает SIGKILL
stop посылает SIGTERM, и через 10 секунд (настраивается) посылает SIGKILL 
SIGTERM - сигнал остановки приложения
SIGKILL - безусловное завершение процесса

## Docker kill
![изображение](https://user-images.githubusercontent.com/85208391/129980586-53f507ff-6ba9-4e5f-8f16-e02340e6bbee.png)

![изображение](https://user-images.githubusercontent.com/85208391/129980598-40cecdbd-1688-4418-a4c2-1325245137c1.png)

## docker system df

    • Отображает сколько дискового пространства занято образами, контейнерами и volume’ами 
    • Отображает сколько из них не используется и возможно удалить 

![изображение](https://user-images.githubusercontent.com/85208391/129980726-35670ab2-88ea-4e83-8932-e5380ea6555a.png)

## docker rm & rmi

    • rm удаляет контейнер, можно добавить флаг -f, чтобы удалялся работающий container(будет послан sigkill) 
    • rmi удаляет image, если от него не зависят запущенные контейнеры 

 ![изображение](https://user-images.githubusercontent.com/85208391/129980828-967d5726-548c-402a-af51-9f59ae8965f0.png)

## Docker-контейнеры

![изображение](https://user-images.githubusercontent.com/85208391/129981147-633d8fe5-94ff-4223-b8ea-22780b140d19.png)

Создаю docker machine
![изображение](https://user-images.githubusercontent.com/85208391/129981185-0b6eb851-8bb9-48ae-8078-77f2de9e59b7.png)


Чтоб не использовать sudo cоздаю Docker - группу пользователей  

``` sudo groupadd docker ```

и добавлю своего плользователя.

``` sudo usermod -aG docker $USER ```

чтоб не вполнять перезагрузку пк 

```newgrp docker```

Инициализировал окружения
![изображение](https://user-images.githubusercontent.com/85208391/129981609-4d820e77-f0f1-485b-af8b-0e57fdcc7c4e.png)

![изображение](https://user-images.githubusercontent.com/85208391/129981672-67d45fae-0b1e-4144-81da-7e848cb6fc4b.png)

![изображение](https://user-images.githubusercontent.com/85208391/129981704-8b3cc3f5-598f-430a-ad46-8d616732ebc6.png)

![изображение](https://user-images.githubusercontent.com/85208391/129981730-07ea4e40-9aba-4d13-9dba-d6aaa65ff53f.png)

## Повторение практики из демона лекции 

И сравните сами вывод:
docker run --rm -ti tehbilly/htop
docker run --rm --pid host -ti tehbilly/htop

![изображение](https://user-images.githubusercontent.com/85208391/129981803-d2ec4120-df4e-49e7-b980-7beaf32e87d2.png)

![изображение](https://user-images.githubusercontent.com/85208391/129981808-8b204286-4e43-4448-90f2-622539bbc072.png)

Для работы с машиной выполняю команду
``` eval $(docker-machine env docker-host) ```

## Структура репозитория
Требуемые четыре файла были созданы согласно заданитя

## Сборка образа

![изображение](https://user-images.githubusercontent.com/85208391/129982396-996fbc23-13af-40d9-a02a-994dc2cd3710.png)

Запускаю контейнер
docker run --name reddit -d --network=host reddit:latest

проверяю
![изображение](https://user-images.githubusercontent.com/85208391/129983033-36b062c0-5ca1-4ea3-b137-6ca765ff1391.png)

## Docker hub

![изображение](https://user-images.githubusercontent.com/85208391/129983236-564243bf-ce1c-4b3d-a2da-1a9376076643.png)











