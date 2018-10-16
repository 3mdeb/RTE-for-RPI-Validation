#!/bin/bash

sudo apt-get install python-pip
sudo apt-get install python-virtualenv

virtualenv .
source ./bin/activate

pip install robotframework-sshlibrary
pip install robotframework-requests

deactivate
