# -*- coding: utf-8 -*-
"""
Created on Mon Sep 18 05:10:52 2023
At each step solves an outer optimisation problem to update lambda

@author: engs2321
"""

import cvxpy as cp
import numpy as np
import matplotlib.pyplot as plt
import time
import scipy.io as sio
import os
import itertools

from default_settings import *
from aux_functions import *

folder_name = 'results/bilevel_lambda_2023_09_18'
try:
    os.mkdir(folder_name)
except:
    pass


settings = def_settings;
#settings['EOL'] = 0.9999

print("Bilevel lambda optimisation is started!")
start_time = time.time()
sol = solve_optimisation(settings, True, "revenue_per_Qloss")
sio.savemat(folder_name+"/bilevel_"+str(i)+"_.mat", sol)
end_time = time.time()
elapsed_time = end_time - start_time
print(f"Elapsed time: {elapsed_time} seconds")   