# -*- coding: utf-8 -*-
"""
Created on Sun Sep 17 04:38:50 2023

This file tries to find optimal lambda_cal and lambda_cyc by 2D sweep

@author: Volkan Kumtepeli
"""

import matplotlib.pyplot as plt
import itertools

from default_settings import def_settings
from aux_functions import simulate_and_save

settings = def_settings;
settings['folderName'] =  'results/optimal_lambda_2023_09_17'
settings['studyName']  = "mixed"
#settings['EOL'] = 0.9999

# Make a mixed sweep! 
mixed_lambda = itertools.product(range(4,17), range(4,11))  # [4,16], [4,11]

for i, L in enumerate(mixed_lambda):
    #if(i<45): continue
    settings['lambda_cyc'], settings['lambda_cal'] = L # lambda_cal = 50 is max same for cycle. 
    simulate_and_save(settings, i)