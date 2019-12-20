#!/usr/bin/env bash

# Copyright (C) 2019 Michael Joseph Walsh - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the the license.
#
# You should have received a copy of the license with
# this file. If not, please email <mjwalsh@nemonik.com>

vagrant up server
vagrant up agent

# should be wicked fast
echo from localhost:
echo
time wget http://192.168.0.11

# should be wicked fast
echo
echo from server:
echo
vagrant ssh server -- -t 'cd /tmp && time wget http://192.168.0.11'

# should be wicked fast, but isn't
echo
echo from agent:
echo
vagrant ssh agent -- -t 'cd /tmp && time wget http://192.168.0.11'
