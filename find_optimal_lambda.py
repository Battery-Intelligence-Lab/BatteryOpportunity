# -*- coding: utf-8 -*-
"""
Created on Sun Sep 17 04:38:50 2023

This file tries to find optimal lambda_cal and lambda_cyc

@author: Volkan Kumtepeli
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

folder_name = 'results/optimal_lambda_2023_09_17'
try:
    os.mkdir(folder_name)
except:
    pass


settings = def_settings;
#settings['EOL'] = 0.9999

i_now = 0

def simulate_and_save(lambdas):
    global i_now, settings
    settings['lambda_cyc'] = lambdas[0]
    settings['lambda_cal'] = lambdas[1]
    print(f"Starting both: {i_now}-th trial for lambda-cyc = {lambdas[0]}, lambda-cal = {lambdas[1]}")
    start_time = time.time()
    sol = solve_optimisation(settings)
    sio.savemat(folder_name+"/mixed_"+str(i_now)+"_.mat", sol)
    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"Elapsed time: {elapsed_time} seconds")   
    i_now += 1
    return sol['revenue'].sum()


#rev_now = simulate_and_save([0.0001,0.0001])


# Make a mixed sweep! 

mixed_lambda = itertools.product(range(4,17), range(4,11))  # [4,16], [4,11]

for i, L in enumerate(mixed_lambda):
    print(f"Starting both: {i}-th trial for lambda = {L}")
    start_time = time.time()
    settings['lambda_cyc'] = L[0]  # lambda_cal = 50 is max same for cycle. 
    settings['lambda_cal'] = L[1]  # lambda_cal = 50 is max same for cycle. 
    sol = solve_optimisation(settings)
    sio.savemat(folder_name+"/mixed_"+str(i)+"_.mat", sol)
    end_time = time.time()
    elapsed_time = end_time - start_time

    print(f"Elapsed time: {elapsed_time} seconds")   