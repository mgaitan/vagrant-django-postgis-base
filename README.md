vagrant-preciosa-base
======================

A Vagrant box based on Ubuntu precise32, configured for Django development according to Torchbox's adopted practices and customized
for the development of the `Preciosa <https://github.com/mgaitan/preciosa>`_ project. Things preinstalled beyond the base precise32 box include:

* postgresql 9.1 (with locale fixed to create databases as UTF-8)
* postgis 2.0.4
* virtualenv and virtualenvwrapper
* a pip download cache pre-seeded with Django, more or less current dependencies of Preciosa and various other common packages
* git (sometimes required for pip dependencies that aren't in PyPI)
* Node.js, CoffeeScript and LESS

This box will successfully build from a vanilla precise32 base box, but using vagrant-django-base instead will skip some of the time-consuming initial setup.

Build instructions
------------------

Optionally - Edit `./install.sh` and enter your locale and country code. Default is `es_AR-UTF-8` and `ar`

To generate the .box file:

    ./build.sh

To install locally:

    vagrant box add django-postgis-base-v2.1 django-postgis-base-v2.1.box
