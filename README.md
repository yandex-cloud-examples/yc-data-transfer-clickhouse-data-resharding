# Перешардирование данных в кластере Yandex Managed Service for ClickHouse®

С помощью сервиса Data Transfer вы можете перенести вашу базу данных из шардированного кластера-источника [Yandex Managed Service for ClickHouse®](https://yandex.cloud/ru/docs/managed-clickhouse) в кластер-приемник Yandex Managed Service for ClickHouse® с другой конфигурацией шардов.

Этот способ позволяет перераспределить данные шардированных таблиц по новой конфигурации шардов кластера ClickHouse®.

Настройка через Terraform описана в [практическом руководстве](https://yandex.cloud/ru/docs/data-transfer/tutorials/mch-mch-resharding), необходимый для настройки конфигурационный файл [data-transfer-mch-mch-resharding.tf](https://github.com/yandex-cloud-examples/yc-data-transfer-clickhouse-data-resharding/blob/main/data-transfer-mch-mch-resharding.tf) расположен в этом репозитории.
