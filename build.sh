#!/bin/bash

BOX_NAME=django-base-postgis
BOX_VERSION=2.1
BOX=${BOX_NAME}-v${BOX_VERSION}

# to build django-base-v2.box:
vagrant up
rm -f ${BOX}.box
vagrant package --output ${BOX}.box

# to install locally:
vagrant box add ${BOX} ${BOX}.box
