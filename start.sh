#!/usr/bin/env bash

sed -e 's/HOSTIP/${HOSTIP}/g' docker-compose.yml | docker-compose --file - up -d --build
