#!/bin/bash
NODE=http://etcd:4001

# WARNING make sure this is consistent between start.sh and reload.sh
haproxy -D -f /etc/haproxy/haproxy.cfg -p /var/haproxy/haproxy.pid -sf $(cat /var/haproxy/haproxy.pid)

# save SLING_ env for other scripts
set | grep SLING_ > /tmp/SLING_ENV.sh
echo "SLING_ environment:"
cat /tmp/SLING_ENV.sh

# log changes of interesting files
./logchanges.sh /etc/haproxy/haproxy.cfg

# confd watches etcd and triggers reload.sh upon changes
/usr/local/bin/confd -interval=2 --config-file=/etc/confd/conf.d/haproxy.toml -node=$NODE
