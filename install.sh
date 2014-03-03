#!/bin/bash

# Script to set up a Django project on Vagrant.

# Installation settings

LOCAL_LOCALE=es_AR.UTF-8
COUNTRY=ar

PGSQL_VERSION=9.1
POSTGIS_VERSION=2.0.4
GEOS_VERSION=3.3.9


# Need to fix locale so that Postgres creates databases in UTF-8
cp -p /vagrant_data/etc-bash.bashrc /etc/bash.bashrc
locale-gen ${LOCAL_LOCALE}
dpkg-reconfigure locales

export LANGUAGE=${LOCAL_LOCALE}
export LANG=${LOCAL_LOCALE}
export LC_ALL=${LOCAL_LOCALE}

# Change to local mirror
# from https://github.com/Tokutek/vagrant-tokutek-builder/commit/b88e5543e6eb6bc8291d0599d017c8a918fca84d
if ! grep -q ${COUNTRY}'\.archive\.ubuntu\.com' /etc/apt/sources.list; then
    sed -i'' -e 's/[a-z]*\.archive\.ubuntu\.com/'${COUNTRY}'.archive.ubuntu.com/g' /etc/apt/sources.list
fi


# Install essential packages from Apt
apt-get update -y
# Python dev packages
apt-get install -y build-essential python python-dev
# python-setuptools being installed manually
wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python
# Dependencies for image processing with Pillow (drop-in replacement for PIL)
# supporting: jpeg, tiff, png, freetype, littlecms
# (pip install pillow to get pillow itself, it is not in requirements.txt)
apt-get install -y libjpeg-dev libtiff-dev zlib1g-dev libfreetype6-dev liblcms2-dev 
# for lxml/scrapy
apt-get install -y libxslt-dev libffi-dev
#apt-get install -y imagemagick xsltproc libxml2-utils dblatex libcunit1 libcunit1-dev 
# Git (we'd rather avoid people keeping credentials for git commits in the repo, but sometimlibxml2-dev libxslt-deves we need it for pip requirements that aren't in PyPI)
apt-get install -y git mercurial


# Postgresql
if ! command -v psql; then
    # Install postgresql and postgis with dependencies
    apt-get install -y libgdal1-1.7.0 libgdal1-dev python-gdal binutils gdal-bin
    apt-get install -y build-essential postgresql-${PGSQL_VERSION} postgresql-server-dev-${PGSQL_VERSION} libxml2-dev libproj-dev libjson0-dev xsltproc docbook-xsl docbook-mathml libpq-dev libgdal1-dev

    wget http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2
    tar xfj geos-${GEOS_VERSION}.tar.bz2
    cd geos-${GEOS_VERSION}
    ./configure && make && make install
    cd ..
    rm -rf geos-${GEOS_VERSION}/ geos-${GEOS_VERSION}.tar.bz2

    wget http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz
    tar xfz postgis-${POSTGIS_VERSION}.tar.gz
    cd postgis-${POSTGIS_VERSION}
    ./configure && make && make install
    ldconfig
    make comments-install
    cd ..
    rm -rf postgis-${POSTGIS_VERSION}/ postgis-${POSTGIS_VERSION}.tar.gz

    ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/shp2pgsql
    ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/pgsql2shp
    ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/raster2pgsql

    cp /vagrant_data/pg_hba.conf /etc/postgresql/${PGSQL_VERSION}/main/
    /etc/init.d/postgresql reload
fi

apt-get clean -y
rm setuptools*.tar.gz

# create gis ready db 'preciosa' under de user dev
sudo -u postgres psql -c "CREATE ROLE dev LOGIN PASSWORD 'dev' SUPERUSER VALID UNTIL 'infinity';"
sudo -u postgres createdb template_postgis
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/$PGSQL_VERSION/contrib/postgis-$POSTGIS_VERSION/postgis.sql
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/$PGSQL_VERSION/contrib/postgis-$POSTGIS_VERSION/spatial_ref_sys.sql
sudo -u postgres psql -d template_postgis -f /usr/share/postgresql/$PGSQL_VERSION/contrib/postgis_comments.sql
sudo -u postgres psql -c "CREATE DATABASE preciosa WITH ENCODING='UTF8' OWNER=dev TEMPLATE=template_postgis LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8' CONNECTION LIMIT=-1;"


# virtualenv global setup
if ! command -v pip; then
    easy_install -U pip
fi
if [[ ! -f /usr/local/bin/virtualenv ]]; then
    pip install virtualenv virtualenvwrapper stevedore virtualenv-clone
fi

# bash environment global setup
cp -p /vagrant_data/bashrc /home/vagrant/.bashrc

if [[ ! -e /home/vagrant/.pip_download_cache ]]; then
    su - vagrant -c "mkdir -p /home/vagrant/.pip_download_cache && \
        virtualenv /home/vagrant/yayforcaching && /home/vagrant/yayforcaching/bin/pip install wheel && \
        PIP_DOWNLOAD_CACHE=/home/vagrant/.pip_download_cache /home/vagrant/yayforcaching/bin/pip wheel --wheel-dir=/home/vagrant/.pip_download_cache -r /vagrant_data/common_requirements.txt scrapy && \
        rm -rf /home/vagrant/yayforcaching"
fi
