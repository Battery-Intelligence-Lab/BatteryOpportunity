# -*- coding: utf-8 -*-
"""
Created on Mon Sep 18 05:10:52 2023
At each step solves an outer optimisation problem to update lambda

@author: Volkan Kumtepeli
"""

import matplotlib.pyplot as plt
import itertools

from default_settings import def_settings
from aux_functions import revenue_per_Qloss, simulate_and_save

settings = def_settings;
settings['folderName'] =  'results/mppt_lambda_2023_09_18'
settings['studyName']  = "mppt"

#settings['EOL'] = 0.9999

# i = 1
# print("MPPT lambda optimisation is started!")
# # ----> new_revenue_per_Qloss = -bat['J_revenue'].value/np.sum(bat['Qloss'].value)
#simulate_and_save(settings, i, revenue_per_Qloss)

# i = 2
# print("MPPT lambda optimisation is started!")
# # ----> new_revenue_per_Qloss = -bat['J_revenue'].value/np.sum(bat['Qloss'].value)/(1 + np.sum(np.abs(np.diff(bat['c_kWh'].value))))
# simulate_and_save(settings, i, revenue_per_Qloss)


# ----> FAILED DONT TRY : new_revenue_per_Qloss = -bat['J_revenue'].value/np.sum(bat['Qloss'].value)/(0.001 + np.std(bat['c_kWh'].value))
# ----> FAILED DONT TRY : new_revenue_per_Qloss = -bat['J_revenue'].value/np.sum(bat['Qloss'].value)/(0.001 + np.std(np.diff(bat['c_kWh'].value)/bat['c_kWh'].value[:-1])  )


i = 3
print("MPPT lambda optimisation std is started!")
# ----> new_revenue_per_Qloss = -bat['J_revenue'].value/np.sum(bat['Qloss'].value)/(0.001 + np.std(np.diff(bat['c_kWh'].value)/bat['c_kWh'].value[:-1])  )
simulate_and_save(settings, i, revenue_per_Qloss)