#!/bin/sh
set -e
gateway=$(ip r | sed -n -E 's|default via ([^ ]+) .*|\1|p')
if [ -n "${DNS}" ]; then
  ip route add "${DNS}" via "${gateway}"
  echo "nameserver ${DNS}" >"/etc/resolv.conf"
fi
if [ -z "${ADDRESS}" ]; then echo "The ADDRESS environment variable must be set!" >&2; exit 1; fi
if [ -z "${USER}" ]; then echo "The USER environment variable must be set!" >&2; exit 1; fi
if [ -z "${PASSWORD}" ]; then echo "The PASSWORD environment variable must be set!" >&2; exit 1; fi

{
  echo "Address: ${ADDRESS}"
  echo "Port: ${PORT}"
  echo "User: ${USER}"
  echo "Password: ${PASSWORD}"
  echo
} | column -L -t

ip route add "${ADDRESS}" via "${gateway}"
ip tuntap add dev tun0 mode tun
ip addr add 10.0.0.1/24 dev tun0
ip link set tun0 up
ip route del default
ip route add default dev tun0

exec tun2socks -loglevel warn -device tun0 -proxy "socks5://${USER}:${PASSWORD}@${ADDRESS}:${PORT}"