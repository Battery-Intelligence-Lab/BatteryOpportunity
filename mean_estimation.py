# -*- coding: utf-8 -*-
"""
Created on Mon Sep 25 23:15:49 2023

Considering that the lambda value does not change and mapping is not easy to fin
we just take a moving average. 

@author: Volkan Kumtepeli
"""

import matplotlib.pyplot as plt
import itertools
import numpy as np

from default_settings import def_settings
from aux_functions import moving_average_filter, simulate_and_save


def geo_mean_overflow(iterable): # https://stackoverflow.com/questions/43099542/python-easy-way-to-do-geometric-mean-in-python
    return np.exp(np.log(iterable).mean())

settings = def_settings;
settings['folderName'] =  'results/mean_window_2023_09_26'


window_length_d = [7, 15, 30, 60, 90] # from 7 day, 15 days, 30, 60, 90


settings['studyName']  = "mean_window"
settings['meanFunction'] = np.mean
for i, window in enumerate(window_length_d):
    settings['lambda_cyc'], settings['lambda_cal'] = [0.01, 0.01]
    settings['window_length_d'] = window
    simulate_and_save(settings, i, simFunction=moving_average_filter)


settings['studyName']  = "geo_mean_window"
settings['meanFunction'] = geo_mean_overflow
for i, window in enumerate(window_length_d):
    settings['lambda_cyc'], settings['lambda_cal'] = [0.01, 0.01]
    settings['window_length_d'] = window
    simulate_and_save(settings, i, simFunction=moving_average_filter)