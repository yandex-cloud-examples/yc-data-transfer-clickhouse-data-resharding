# Миграция шардированного кластера Managed Server for ClickHouse® c помощью Yandex Data Transfer

С помощью сервиса Data Transfer вы можете перенести базу данных из шардированного кластера [Yandex Managed Service for ClickHouse®](https://cloud.yandex.ru/docs/managed-clickhouse) в новый кластер для перераспределения данных шардированных таблиц в новой конфигурации шардов. Настройка через Terraform описана в [практическом руководстве](https://cloud.yandex.ru/docs/data-transfer/tutorials/mch-mch-resharding), необходимый для настройки конфигурационный файл [data-transfer-mch-mch-resharding.tf](https://github.com/yandex-cloud-examples/yc-data-transfer-clickhouse-data-resharding/blob/main/data-transfer-mch-mch-resharding.tf) расположен в этом репозитории.