#!/usr/bin/env bash
set -eux

ip addr add 100.64.0.0/12 dev lo

exec "$@"
