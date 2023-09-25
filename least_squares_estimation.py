# -*- coding: utf-8 -*-
"""
Created on Mon Sep 25 07:03:55 2023

This file is for least squares solutions with moving window. 

@author: Volkan Kumtepeli
"""

import matplotlib.pyplot as plt
import itertools

from default_settings import def_settings
from aux_functions import moving_least_squares, simulate_and_save

settings = def_settings;
settings['folderName'] =  'results/ls_window_2023_09_25'
settings['studyName']  = "ls_window"

window_length_d = [7, 15, 30, 60, 90] # from 7 day, 15 days, 30, 60, 90

for i, window in enumerate(window_length_d):
    #if(i<45): continue
    settings['lambda_cyc'], settings['lambda_cal'] = [0.01, 0.01]
    settings['window_length_d'] = window
    simulate_and_save(settings, i, simFunction=moving_least_squares)



