#!/bin/bash
set -Eeuo pipefail

echo "----- install prerequisite packages -----"
apk update --quiet
apk add sudo bash sudo curl curl-dev build-base libidn2 libffi-dev libxml2-dev libxml2-utils openssl-dev python3 python3-dev py3-pip cargo
