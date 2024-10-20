# Задание 1. Планирование

## Список схем
Схема 1 (Шардирование):
```shell
./mongo-sharding/scheme-1.drawio
```
Схема 2 (Репликация):
```shell
./mongo-sharding-repl/scheme-2.drawio
```
Схема 3 (Кэширование):
```shell
./sharding-repl-cache/scheme-3.drawio
```

# Задание 2. Шардирование

## Запуск
Запуск, инициализация БД и контроль распределения данных по шардам выполняется файлом
```shell
./mongo-sharding/start-app.bat
```
## Проверка через приложение
Откройте в браузере http://localhost:8080

# Задание 3. Репликация

## Запуск
Запуск, инициализация БД и контроль распределения данных по шардам выполняется файлом
```shell
./mongo-sharding-repl/start-app.bat
```
## Проверка через приложение
Откройте в браузере http://localhost:8080

# Задание 4. Кэширование

## Запуск
Запуск, инициализация БД и контроль распределения данных по шардам выполняется файлом
```shell
./sharding-repl-cache/start-app.bat
```
## Проверка через приложение
Откройте в браузере http://localhost:8080

## Проверка работы кэша
1. Сразу после запуска приложения, в контейнере redis-master проверьте состояние кэша
```shell
winpty docker exec -it redis-master redis-cli

> keys *
```
Результат:
```shell
(empty array)
```
2. Выполните запрос
```shell
http://localhost:8080/helloDoc/users
```
3. Еще раз проверьте состояние кэша командой из п.1 и убедитесь что запрос из п.2 закэшировался

# Задание 4. Service Discovery и балансировка с API Gateway
Расположение схемы 4:
```shell
./sharding-repl-cache/scheme-4.drawio
```
# Задание 5. CDN
Расположение схемы 5:
```shell
./sharding-repl-cache/scheme-5.drawio
```