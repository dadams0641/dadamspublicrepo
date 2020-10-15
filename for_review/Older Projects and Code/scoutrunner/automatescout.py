#!/bin/env python3

import sys
import re

envs = {
    "DEV": 183406521668,
    "POC": 913474001465,
    "QA": 452492757303,
    "CORP": 496307432785,
    "STAGING": 438313809893,
    "SECLOGS": "031825756638",
    "HUB": 987577772363,
    "PROD": 182702502117
}

for e in envs:
    print('ansible-playbook scoutrunner.yml -vvv --extra-vars "env=' + e + ' scout_id=' + str(envs[e]) + '"')
