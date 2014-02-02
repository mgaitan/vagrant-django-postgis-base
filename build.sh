#!/bin/bash

BOX_NAME=django-base-postgis
BOX_VERSION=2.1
BOX=${BOX_NAME}-v${BOX_VERSION}

vagrant up
echo "VM Booted and "
rm -f ${BOX}.box
vagrant package --output ${BOX}.box

# to install locally:
vagrant box add ${BOX} ${BOX}.box
