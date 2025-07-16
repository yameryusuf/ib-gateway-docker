#!/bin/sh
set -e

if [ -z "$TWS_USERID" ] || [ -z "$TWS_PASSWORD" ]; then
  if [ -n "$AWS_SECRET_NAME" ]; then
    SECRET=$(aws secretsmanager get-secret-value --secret-id "$AWS_SECRET_NAME" --region "$AWS_REGION" --query SecretString --output text)
    TWS_USERID=$(echo "$SECRET" | jq -r '.username')
    TWS_PASSWORD=$(echo "$SECRET" | jq -r '.password')
  elif [ -n "$AWS_SSM_PARAMETER" ]; then
    SECRET=$(aws ssm get-parameter --name "$AWS_SSM_PARAMETER" --region "$AWS_REGION" --with-decryption --query Parameter.Value --output text)
    TWS_USERID=$(echo "$SECRET" | jq -r '.username')
    TWS_PASSWORD=$(echo "$SECRET" | jq -r '.password')
  fi
fi

if [ -z "$TWS_USERID" ] || [ -z "$TWS_PASSWORD" ]; then
  echo "TWS credentials not provided" >&2
  exit 1
fi

export TWS_USERID TWS_PASSWORD
export DISPLAY=:1

rm -f /tmp/.X1-lock
Xvfb :1 -ac -screen 0 1024x768x16 &

if [ -n "$VNC_SERVER_PASSWORD" ]; then
  echo "Starting VNC server"
  /root/scripts/run_x11_vnc.sh &
fi

envsubst < "${IBC_INI}.tmpl" > "${IBC_INI}"

/root/scripts/fork_ports_delayed.sh &

/root/ibc/scripts/ibcstart.sh "${TWS_MAJOR_VRSN}" -g \
     "--tws-path=${TWS_PATH}" \
     "--ibc-path=${IBC_PATH}" "--ibc-ini=${IBC_INI}" \
     "--user=${TWS_USERID}" "--pw=${TWS_PASSWORD}" "--mode=${TRADING_MODE}" \
     "--on2fatimeout=${TWOFA_TIMEOUT_ACTION}"
