# Infrastructure for the Yandex Cloud Managed Service for ClickHouse cluster and Data Transfer.
#
# RU: https://cloud.yandex.ru/docs/managed-clickhouse/tutorials/data-migration
# EN: https://cloud.yandex.com/en/docs/managed-clickhouse/tutorials/data-migration
#
# Set source and target clusters settings.
locals {
  # Source cluster settings:
  source_cluster = ""   # Set the source cluster identifier.
  source_db_name = ""   # Set the source cluster database name.
  source_user    = ""   # Set the source cluster username.
  source_pwd     = ""   # Set the source cluster password.
  # Target cluster settings:
  target_clickhouse_version = "" # Set the ClickHouse version.
  target_user               = "" # Set the target cluster username.
  target_password           = "" # Set the target cluster password.
}

resource "yandex_vpc_network" "network" {
  description = "Network for the Managed Service for ClickHouse cluster"
  name        = "network"
}

resource "yandex_vpc_subnet" "subnet-a" {
  description    = "Subnet in the ru-central1-a availability zone"
  name           = "subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.1.0.0/16"]
}

resource "yandex_vpc_subnet" "subnet-d" {
  description    = "Subnet in the ru-central1-d availability zone"
  name           = "subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["172.16.0.0/16"]
}

resource "yandex_vpc_security_group" "security-group" {
  description = "Security group for the Managed Service for ClickHouse cluster"
  network_id  = yandex_vpc_network.network.id

  ingress {
    description    = "Allow incoming traffic on port 9440 from any IP address"
    protocol       = "TCP"
    port           = 9440
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow incoming traffic on port 8443 from any IP address"
    protocol       = "TCP"
    port           = 8443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_mdb_clickhouse_cluster" "clickhouse-cluster" {
  name               = "clickhouse-cluster"
  description        = "Managed Service for ClickHouse cluster"
  environment        = "PRODUCTION"
  network_id         = yandex_vpc_network.network.id
  security_group_ids = [yandex_vpc_security_group.security-group.id]

  clickhouse {
    resources {
      resource_preset_id = "s2.micro" # 2 vCPU, 8 GB RAM
      disk_type_id       = "network-ssd"
      disk_size          = 30 # GB
    }
  }

  zookeeper {
    resources {
      resource_preset_id = "s2.micro" # 2 vCPU, 8 GB RAM
      disk_type_id       = "network-ssd"
      disk_size          = 10 # GB
    }
  }

  host {
    type             = "CLICKHOUSE"
    zone             = "ru-central1-a"
    subnet_id        = yandex_vpc_subnet.subnet-a.id
    assign_public_ip = true # Required for connection from the Internet
    shard_name       = "shard1"
  }

  host {
    type             = "CLICKHOUSE"
    zone             = "ru-central1-a"
    subnet_id        = yandex_vpc_subnet.subnet-a.id
    assign_public_ip = true # Required for connection from the Internet
    shard_name       = "shard1"
  }

  host {
    type             = "CLICKHOUSE"
    zone             = "ru-central1-d"
    subnet_id        = yandex_vpc_subnet.subnet-d.id
    assign_public_ip = true # Required for connection from the Internet
    shard_name       = "shard2"
  }

  host {
    type             = "CLICKHOUSE"
    zone             = "ru-central1-d"
    subnet_id        = yandex_vpc_subnet.subnet-d.id
    assign_public_ip = true # Required for connection from the Internet
    shard_name       = "shard3"
  }

  host {
    type             = "CLICKHOUSE"
    zone             = "ru-central1-a"
    subnet_id        = yandex_vpc_subnet.subnet-a.id
    assign_public_ip = true # Required for connection from the Internet
    shard_name       = "shard4"
  }

  host {
    type      = "ZOOKEEPER"
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.subnet-a.id
  }

  host {
    type      = "ZOOKEEPER"
    zone      = "ru-central1-d"
    subnet_id = yandex_vpc_subnet.subnet-d.id
  }

  host {
    type      = "ZOOKEEPER"
    zone      = "ru-central1-d"
    subnet_id = yandex_vpc_subnet.subnet-d.id
  }

  database {
    name = local.source_db_name
  }

  user {
    name     = local.target_user
    password = local.target_password
    permission {
      database_name = local.source_db_name
    }
  }
}

resource "yandex_datatransfer_endpoint" "managed-clickhouse-source" {
  description = "Source endpoint for Managed Service for ClickHouse server"
  name        = "managed-clickhouse-source"
  settings {
    clickhouse_source {
      connection {
        connection_options {
          mdb_cluster_id = local.source_cluster
          database       = local.source_db_name
          user           = local.source_user
          password {
            raw = local.source_pwd
          }
        }
      }
    }
  }
}

resource "yandex_datatransfer_endpoint" "managed-clickhouse-target" {
  description = "Target endpoint for the Managed Service for ClickHouse cluster"
  name        = "managed-clickhouse-target"
  settings {
    clickhouse_target {
      connection {
        connection_options {
          mdb_cluster_id = yandex_mdb_clickhouse_cluster.clickhouse-cluster.id
          database       = local.source_db_name
          user           = local.target_user
          password {
            raw = local.target_password
          }
        }
      }
      sharding {
        round_robin {}
      }
    }
  }
}

resource "yandex_datatransfer_transfer" "clickhouse-transfer" {
  description = "Transfer between two Managed Service for ClickHouse clusters"
  name        = "transfer-from-managed-clickhouse-to-managed-clickhouse"
  source_id   = yandex_datatransfer_endpoint.managed-clickhouse-source.id
  target_id   = yandex_datatransfer_endpoint.managed-clickhouse-target.id
  type        = "SNAPSHOT_ONLY" # Copy all data from the source server.
}
