#!/usr/bin/env python3

import os
import sys
import subprocess


unix_team = {
  "Drew Happli": "ahappli",
  "James Mace": "jamemace",
  "Jon Lickey": "jolickey",
  "Mike Berisford": "mberisfo",
  "Mike Burger": "mburger",
  "Rob Wheeler": "rwheeler",
  "Reporting Admin": "rptadmin"
}


print("Adding Unix Team")

for ut in unix_team:
    print("Adding User " + ut)
    os.system('useradd -G admins -c "' + ut + '" ' + unix_team[ut])
