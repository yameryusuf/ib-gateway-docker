#!/bin/bash
apt-get update -y
apt-get install -y docker.io awscli jq
systemctl enable docker
systemctl start docker

docker run -d --restart unless-stopped --name ib-gateway \
  -e AWS_REGION=${region} \
  -e AWS_SSM_PARAMETER=${ssm_param} \
  -e TRADING_MODE=${trading_mode} \
  ghcr.io/unusualalpha/ib-gateway:latest
