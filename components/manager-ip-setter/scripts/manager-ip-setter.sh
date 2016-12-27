#! /usr/bin/env bash
set -e

ip=$(/usr/sbin/ip a s | /usr/bin/grep -oE 'inet [^/]+' | /usr/bin/cut -d' ' -f2 | /usr/bin/grep -v '^127.' | /usr/bin/grep -v '^169.254.' | /usr/bin/head -n1)

echo "Setting manager IP to: ${ip}"

echo "Updating cloudify-amqpinflux"
/usr/bin/sed -i -e "s/AMQP_HOST=.*/AMQP_HOST="'"'"${ip}"'"'"/" /etc/sysconfig/cloudify-amqpinflux
/usr/bin/sed -i -e "s/INFLUXDB_HOST=.*/INFLUXDB_HOST="'"'"${ip}"'"'"/" /etc/sysconfig/cloudify-amqpinflux

echo "Updating cloudify-riemann"
/usr/bin/sed -i -e "s/RABBITMQ_HOST=.*/RABBITMQ_HOST="'"'"${ip}"'"'"/" /etc/sysconfig/cloudify-riemann

echo "Updating cloudify-mgmtworker"
/usr/bin/sed -i -e "s#MANAGER_FILE_SERVER_URL="'"'"http://.*:53229"'"'"#MANAGER_FILE_SERVER_URL="'"'"http://${ip}:53229"'"'"#" /etc/sysconfig/cloudify-mgmtworker
/usr/bin/sed -i -e "s#MANAGER_FILE_SERVER_BLUEPRINTS_ROOT_URL="'"'"http://.*:53229/blueprints"'"'"#MANAGER_FILE_SERVER_BLUEPRINTS_ROOT_URL="'"'"http://${ip}:53229/blueprints"'"'"#" /etc/sysconfig/cloudify-mgmtworker
/usr/bin/sed -i -e "s#MANAGER_FILE_SERVER_DEPLOYMENTS_ROOT_URL="'"'"http://.*:53229/deployments"'"'"#MANAGER_FILE_SERVER_DEPLOYMENTS_ROOT_URL="'"'"http://${ip}:53229/deployments"'"'"#" /etc/sysconfig/cloudify-mgmtworker

echo "Updating logstash.conf"
/usr/bin/sed -i -e "s/host => "'"'".*"'"'"/host => "'"'"${ip}"'"'"/" /etc/logstash/conf.d/logstash.conf

echo "Updating broker_config.json"
/usr/bin/sed -i -e "s/"'"'"broker_hostname"'"'": "'"'".*"'"'"/"'"'"broker_hostname"'"'": "'"'"${ip}"'"'"/" /opt/mgmtworker/work/broker_config.json

echo "Done!"