vagrant-preciosa-base
======================

A Vagrant box based on Ubuntu saucy32, configured for Django development according to Torchbox's adopted practices and customized
for the development of the `Preciosa <https://github.com/mgaitan/preciosa>`_ project. Things preinstalled beyond the base saucy32 box include:

* postgresql 9.1 (with locale fixed to create databases as UTF-8)
* postgis 2.0.4
* virtualenv and virtualenvwrapper
* a pip download cache pre-seeded with Django, more or less current dependencies of Preciosa and various other common packages in Wheel format (already compiled, i.e. faster than sources)
* git (sometimes required for pip dependencies that aren't in PyPI)
* a predefined GIS ready *"preciosa"* postgres database under the user 'dev' (password: dev)

This box will successfully build from a vanilla precise32 base box, but using vagrant-django-base instead will skip some of the time-consuming initial setup.

This box could be downloaded from http://lab.nqnwebs.com/preciosa-base-v0.1.box

Build instructions
------------------

Optionally - Edit `./install.sh` and enter your locale and country code

To generate the .box file:

    ./build.sh

To install locally:

    vagrant box add preciosa-base-v0.1 preciosa-base-v0.1.box
