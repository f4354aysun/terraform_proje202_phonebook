#!/bin/bash
yum update -y
yum install python3 -y
pip3 install flask
pip3 install flask_mysql
yum install git -y
TOKEN="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"
cd /home/ec2-user
git clone https://$TOKEN@github.com/f4354aysun/ter_project_01.git
python3 /home/ec2-user/ter_project_01/phonebook-app.py