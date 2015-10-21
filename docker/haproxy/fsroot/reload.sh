#!/bin/bash
# called when confd detects changes
ME=$(basename $0)
IN=/tmp/backends.txt
OUT=/etc/haproxy/haproxy.cfg
BASE=/etc/haproxy/haproxy-base.cfg
TMP=/tmp/haproxy-tmp.cfg

# TODO might need better handling of duplicate domains
# for now we just sort -u them
grep -v '^ *$' < $IN  | sort | awk -F# '{ print $1 ":" $2 ":" $3}' | sort -u > $TMP


function generate_config() {
	# get unique list of domains, IPs, ports into a bash array
	UNIQ=$(grep -v '^ *$' | sort | awk -F# '{ print $1 ":" $2 ":" $3}' | sort -u)

	echo "# acl and use generated by $ME"
	for i in ${UNIQ[@]}
	do
	  # $1:domain, $2:IP, $3:port
	  set $(echo $i | tr ':' ' ')
	  echo "acl H_$1 hdr(host) -i $1"
	  echo "use_backend B_$1 if H_$1"
	done

	echo
	echo "# backends generated by $ME"
	for i in ${UNIQ[@]}
	do
	  # $1:domain, $2:IP, $3:port
	  set $(echo $i | tr ':' ' ')
	  echo "backend B_$1"
	  echo "    description $1 backend (from $ME)"
	  echo "    balance source"
	  echo "    option httpclose"
	  echo "    option forwardfor"
	  echo "    # TODO testing options for connection reset problem"
	  echo "    option forceclose"
	  echo "    server S_$1 $2:$3 check"
	  echo
	done
}

generate_config < $IN > $TMP


# TODO only reload if $TMP changed?
echo "servers list updated, reloading haproxy"
cat $BASE $TMP > $OUT

# WARNING make sure this is consistent between start.sh and reload.sh
haproxy -D -f /etc/haproxy/haproxy.cfg -p /var/haproxy/haproxy.pid -sf $(cat /var/haproxy/haproxy.pid)
