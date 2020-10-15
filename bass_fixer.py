#!/bin/env python3


import os
import subprocess
import sys
import re

bass_dict = {}
page_count = 1
page_max = 954


while page_count <= 20:
    if page_count > 1 and page_count < page_max + 1:
        page = "/page-"
        count = page_count
    elif page_count == 1:
        page = "/"
        count = ""
    else:
        print("We're All Done Here")
        sys.exit(0)
    page_count = page_count + 1
    bass_thread = "https://www.avsforum.com/threads/the-ultimate-list-of-bass-in-movies-w-frequency-charts.2763785" + page + str(count)
    img_finder = subprocess.Popen('curl -s ' + bass_thread, shell=True, stdout=subprocess.PIPE)
    for imgfind in img_finder.stdout:
        imgfind = imgfind.decode()
        imgfind = imgfind.rstrip()
        igf = re.findall(r'data-url=\"(http.*imgur.*)\" alt*=',imgfind)
        title_find = re.findall(r': .*center\"><b>(.*)<',imgfind)
        for titfind in title_find:
            title = titfind
            #print(title)
            hold_bass_dict[title]=''
        for ifind in igf:            
            imgfnd = ifind.split(" ")
            #print(imgfnd[0]) 
            hold_bass_dict.update( {title : imgfnd[0]} )


for bass_dict in hold_bass_dict:
    print(bass_dict, hold_bass_dict[bass_dict])


'''
bass_thread = "https://www.avsforum.com/threads/the-ultimate-list-of-bass-in-movies-w-frequency-charts.2763785" + page + str(count) + " | grep -i imgur | grep url"
curl -s https://www.avsforum.com/threads/the-ultimate-list-of-bass-in-movies-w-frequency-charts.2763785/ | grep -i imgur
'''
