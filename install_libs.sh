#!/bin/bash

sudo apt-get install python-pip
sudo apt-get install python-virtualenv
# temporary requirement:
sudo apt-get install sshpass

virtualenv .
source ./bin/activate

pip install robotframework-sshlibrary
pip install robotframework-requests

deactivate
