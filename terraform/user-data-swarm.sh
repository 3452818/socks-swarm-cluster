#!/bin/bash
# Установка Docker
sudo apt update && sudo apt install -y docker.io


# Инициализация Swarm
if [ "$is_master" = "true" ]; then
  # Получаем IP мастера через metadata Yandex Cloud
  MASTER_IP=$(curl -s http://metadata.yandexcloud.internal/latest/meta-data/v1/instance/network-interfaces/0/nat-ip)
  sudo docker swarm init --advertise-addr $MASTER_IP
  SWARM_TOKEN=$(sudo docker swarm join-token worker -f | grep -A 2 'join' | tail -1 | awk '{print $5}')
  echo "SWARM_TOKEN=$SWARM_TOKEN" > /tmp/swarm.env
  echo "Master IP: $MASTER_IP" > /tmp/master-ip.txt
else
  # Воркеры получают токен из /tmp/swarm.env
  source /tmp/swarm.env
  sudo docker swarm join --token $SWARM_TOKEN $MASTER_IP:2377
fi

# Создание overlay-сети
if [ "$is_master" = "true" ]; then
  sudo docker network create --driver=overlay socksnet
fi
