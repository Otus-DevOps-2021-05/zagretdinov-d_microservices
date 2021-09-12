# zagretdinov-d_microservices
zagretdinov-d microservices repository

# Устройство Gitlab CI.Построение процесса непрерывной поставки.

## Создаю ветку в репозитории:
```
git checkout -b gitlab-ci-1
```
## Поднимаю docker host:
```
yc compute instance create \
  --name gitlab-host \
  --memory=4 \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=50 \
  --ssh-key ~/.ssh/zagretdinov.pub
```
## Установка Docker
docker-machine create \  
--driver generic \  
--generic-ip-address=62.84.112.231 \  
--generic-ssh-user yc-user \  
--generic-ssh-key ~/.ssh/zagretdinov \  
docker-host

## Установка GitLab-CE
Подключаюсь к хосту и создаю необходимые каталоги:
```
ssh yc-user@62.84.112.231
sudo mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs

cd /srv/gitlab
sudo touch docker-compose.yml
```
```
sudo vim docker-compose.yml

web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'localhost'
  environment:
    GITLAB_OMNIBUS_CONFIG:
      external_url 'http://62.84.112.231'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
```

Запустим gitlab через docker-compose:
```
sudo docker-compose up -d
```
![изображение](https://user-images.githubusercontent.com/85208391/132757650-7ecbcee0-0d24-4036-8617-622c945e1fc3.png)

теперь можно проверить: http://62.84.112.231


Произвел сброс пароля: 
```
sudo touch /srv/gitlab/config/initial_root_password
sudo cat /srv/gitlab/config/initial_root_password
```
Пароль используем его для пользоватля root.

## Настройка:

Отключаю регистрацию новых пользователей:
```
Settings -> General -> Sign-up restrictions 

[ ] Sign-up enabled
```
Создаю группу:
```
Name - homework
Description - Projects for my homework
Visibility - private
```
Создаю проект: example

Для выполнения push с локального хоста в gitlab выполним (Добавление remote):

```
git remote add gitlab http://62.84.112.231/homework/example.git
git push gitlab gitlab-ci-1
```
Пайплайн для GitLab определяется в файле .gitlab-ci.yml

```
stages:
  - build
  - test
  - deploy

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  script:
    - echo 'Testing 1'

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_job:
  stage: deploy
  script:
    - echo 'Deploy'
```
Пушу:
```
git add .gitlab-ci.yml
git commit -m 'add pipeline definition'
git push gitlab gitlab-ci-1
```
Добавляю раннера

На сервере Gitlab CI, выполняю:
```
ssh yc-user@62.84.112.231

sudo docker run -d --name gitlab-runner --restart always -v /srv/gitlabrunner/config:/etc/gitlab-runner -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:latest
```

Регистрация раннера (указываем url сервера gitlab и токен из Settings -> CI/CD -> Pipelines -> Runners ):

```
sudo docker exec -it gitlab-runner gitlab-runner register \
 --url http://62.84.112.231/ \
 --non-interactive \
 --locked=false \
 --name DockerRunner \
 --executor docker \
 --docker-image alpine:latest \
 --registration-token  \
 --tag-list "linux,xenial,ubuntu,docker" \
 --run-untagged
 ```

Если все успешно, то должен появится новый ранер в Settings -> CI/CD -> Pipelines -> Runners секция Available specific runners и после появления ранера должен выполнится пайплайн.

Добавление Reddit в проект

```
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m "Add reddit app"
git push gitlab gitlab-ci-1
```
Изменил описание пайплайна в .gitlab-ci.yml, создаю файл тестов reddit/simpletest.rb:

```
require_relative './app'
require 'test/unit'
require 'rack/test'

set :environment, :test

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_request
    get '/'
    assert last_response.ok?
  end
end
```
Добавил библиотеку rack-test в reddit/Gemfile:
```
gem 'rack-test'
```
## Окружения

Добавиk в .gitlab-ci.yml новые окружения и условия запусков для ранеров
```
image: ruby:2.4.2

stages:
  - build
  - test
  - review
  - stage
  - production

variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'
   
before_script:
  - cd reddit
  - bundle install

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_dev_job:
  stage: review
  script:
    - echo 'Deploy'
  environment:
    name: dev
    url: http://dev.example.com

branch review:
  stage: review
  script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
  environment:
    name: branch/$CI_COMMIT_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.example.com
  only:
    - branches
  except:
    - master

staging:
  stage: stage
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: http://beta.example.com

production:
  stage: production
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: production
    url: http://example.com
```
Для проверки закоммитим файлы с указанием тэга (версии) и запушим в gitlab:

```
git add .gitlab-ci.yml
git commit -m '#5 add ver 2.4.10'
git tag 2.4.10
git push gitlab gitlab-ci-1 --tags
```
