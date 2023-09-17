import cvxpy as cp
import numpy as np
import matplotlib.pyplot as plt
import time
import scipy.io as sio
import os
import itertools

from default_settings import *
from aux_functions import *
import itertools

settings = def_settings;

#folder_name = 'results/sensitivity_2023_09_13_real'
folder_name = 'results/sensitivity_2023_09_13_real'
try:
    os.mkdir(folder_name)
except:
    pass

lambda_trials = [0.00001, 0.0001, 0.001, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.3, 0.4, 
                 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.98, 0.99, 1, 1.01, 1.02, 1.05, 1.1, 
                 1.25, 1.5, 2, 4, 8, 16, 25, 50, 10, 12, 14, 11, 13, 9, 100, 6]


# Change only lambda_cyc
# for i, L in enumerate(lambda_trials):
#     if(i<39): continue
#     print(f"Starting cyc: {i}-th trial for lambda = {L}")
#     start_time = time.time()
#     settings['lambda_cyc'] = L  # lambda_cal = 50 is max same for cycle. 
#     sol = solve_optimisation(settings)
#     sio.savemat(folder_name+"/lambda_cyc_"+str(i)+"_.mat", sol)
#     end_time = time.time()
#     elapsed_time = end_time - start_time

#     print(f"Elapsed time: {elapsed_time} seconds")

# # Change only lambda_cal
# for i, L in enumerate(lambda_trials):
#     if(i<32):
#         continue
#     print(f"Starting cal: {i}-th trial for lambda = {L}")
#     start_time = time.time()
#     settings['lambda_cal'] = L  # lambda_cal = 50 is max same for cycle. 
#     sol = solve_optimisation(settings)
#     sio.savemat(folder_name+"/lambda_cal_"+str(i)+"_.mat", sol)
#     end_time = time.time()
#     elapsed_time = end_time - start_time

#     print(f"Elapsed time: {elapsed_time} seconds") 


 
# # Change both lambda_cal and lambda_cyc
# for i, L in enumerate(lambda_trials):
#     if(i<39): continue
#     print(f"Starting both: {i}-th trial for lambda = {L}")
#     start_time = time.time()
#     settings['lambda_cyc'] = L  # lambda_cal = 50 is max same for cycle. 
#     settings['lambda_cal'] = L  # lambda_cal = 50 is max same for cycle. 
#     sol = solve_optimisation(settings)
#     sio.savemat(folder_name+"/both_"+str(i)+"_.mat", sol)
#     end_time = time.time()
#     elapsed_time = end_time - start_time

#     print(f"Elapsed time: {elapsed_time} seconds")   
    


    

      # Plot
    #   plt.figure(figsize=(10, 6))
    #   plt.plot(bat['AC_Pnett'].value, label="bat['AC_Pnett'].value")
    # #  plt.plot(days, J, label="Total Aging (J)", linewidth=2)
    #   plt.xlabel("Days")
    #   plt.ylabel("Aging")
    #   plt.title("Battery Aging over Time Approaching Expiration")
    #   plt.legend()
    #   plt.grid(True)
    #   plt.show()
      
      
    # Plot
    # plt.figure(figsize=(10, 6))
    # plt.plot(bat['SOC'].value, label="AC['SOC'].value")
    # plt.xlabel("Days")
    # plt.ylabel("Aging")
    # plt.title("Battery Aging over Time Approaching Expiration")
    # plt.legend()
    # plt.grid(True)
    # plt.show()
    
# print("bat['AC_Pnett'] : ", bat['AC_Pnett'].value, '\n')
# print("bat['Pnett'] : ", bat['Pnett'].value, '\n')
# print("bat['Pch']*bat['Pdisch'] : ", bat['Pch'].value *  bat['Pdisch'].value, '\n')

# print("bat['Ebatt'] : ", bat['Ebatt'].value, '\n')
# print("bat['SOC'] : ", bat['SOC'].value, '\n')
# print("max['SOC'] : ", np.max(bat['SOC'].value), '\n')
# print("bat['SOCavg'] : ", bat['SOCavg'].value, '\n')
# print("bat['FEC'] : ", np.cumsum(bat['dFEC'].value), '\n')
# print("bat['Tc'] : ",  bat['Tc'].value, '\n')
# print("Jcal total: ", bat['Qloss_cal'].value, '\n')
# print("Jcyc total: ", bat['Qloss_cyc'].value, '\n')
