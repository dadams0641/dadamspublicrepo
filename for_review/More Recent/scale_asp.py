#!/bin/env python3 

import os
import sys
import subprocess
import json
from time import sleep

sku_size = ''
asp_name = 'CSIE-ASP-PRD'
resource_group = 'Secure_Info_Exchange_CSIE_PRD1'



'''
!!!!Reference Only! Do not put actual code here!!!!

az appservice plan update --name MyAppServicePlan --resource-group MyResourceGroup --sku F1

az appservice plan show --name CSIE-ASP-PRD -g Secure_Info_Exchange_CSIE_PRD1 --query "[sku.name, sku.size]" --output tsv
'''



def scale_down():
    print('az appservice plan update --name ' + asp_name + ' --resource-group ' + resource_group + ' --sku I2')
    os.system('az appservice plan update --name ' + asp_name + ' --resource-group ' + resource_group + ' --sku I2')


def scale_up():
    print('az appservice plan update --name ' + asp_name + ' --resource-group ' + resource_group + ' --sku I3')
    os.system('az appservice plan update --name ' + asp_name + ' --resource-group ' + resource_group + ' --sku I3')


def check_sku():
    skusize = subprocess.Popen('az appservice plan show --name ' + asp_name + ' -g ' + resource_group + ' --query "[sku.size]" --output tsv', shell=True, stdout=subprocess.PIPE)
    for sz in skusize.stdout:
        sz = sz.decode()
        sz = sz.rstrip()
        sku_size = sz
        print('SKU Size is ' + sz)
    if sku_size == "I3":
        print("Size is " + sku_size + ". Scaling Down!")
        scale_down()
    if sku_size == "I2":
        print("Size is " + sku_size + ". Scaling Up!")
        scale_up()


check_sku()
sleep(90)
check_sku()