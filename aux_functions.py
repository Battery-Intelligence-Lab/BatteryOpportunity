# -*- coding: utf-8 -*-
"""
Created on Sun Sep 17 04:34:35 2023

@author: Volkan Kumtepeli
"""

import cvxpy as cp
import numpy as np
import matplotlib.pyplot as plt
import time
import scipy.io as sio
import os

KELVIN = 273.15 

def solve_optimisation(settings, print_SOH = True):
    dt = settings['dt']
    Nh = int(settings['horizon']/dt)
    Nc = int(settings['control-horizon']/dt)
    
    bat_eta_ch, bat_eta_dc  = settings['bat_eta_ch'], settings['bat_eta_dc']
    AC_eta_ch,  AC_eta_dc   = settings['AC_eta_ch'],  settings['AC_eta_dc']
    eta_ch,     eta_dc      = bat_eta_ch*AC_eta_ch,   bat_eta_dc*AC_eta_dc
    
    EOL = settings['EOL']
    Enom =  settings['Enom']
    cost_whole = Enom * settings['price_kWhcap'] / (1.0 - EOL)
    Cr_ch, Cr_dc = settings['C-rate'][0], settings['C-rate'][1]
    
    E0 = settings['E0']
    SOH0 = settings['SOH0']
    Tk0 = settings['Tk0']
    idc = np.genfromtxt('data/' + settings['dataName'])
    
    constr = []
    
    # Battery variables:
    bat = {}
    bat['Pch']      = cp.Variable(Nh)
    bat['Pdisch']   = cp.Variable(Nh)
    bat['Pnett']    = bat['Pch'] - bat['Pdisch']
    bat['Pabs']     = bat['Pch'] + bat['Pdisch']
    bat['rate_ch']  = bat['Pch'] / Enom
    bat['rate_dc']  = bat['Pdisch'] / Enom
    
    bat['Ebatt']    = cp.Variable(Nh+1) # Energy inside bat kWh
    bat['SOC']      = cp.Variable(Nh+1)
    bat['SOCavg']   = (bat['SOC'][1:] + bat['SOC'][:-1])/2.0
    bat['dFEC']     = 0.5*dt*bat['Pabs']/Enom # FEC per time step. 
      
      
    # Temperature model: 
    bat['Tk']       = cp.Variable(Nh+1)
    bat['Tk_avg']   = (bat['Tk'][1:] + bat['Tk'][:-1])/2.0
    bat['Qcell']    = settings['Qcell_ch']*bat['rate_ch'] + settings['Qcell_dc']*bat['rate_dc'] 
    bat['dTk']      = settings['k_Tcell']*((settings['Tamb'] - bat['Tk'][:-1])*settings['alpha_Tcell'] + bat['Qcell'])
    bat['Tc']       = bat['Tk'] - KELVIN
    
    # ageing params: 
    bat['Qloss_cyc_ch_per_h'] = cp.Variable(Nh) # Qloss cycle charging
    bat['Qloss_cal_per_h']    = cp.Variable(Nh) # Qloss calendar
    
    # initial params:
    bat['E0']   = cp.Parameter(1, name="E0", nonneg=True)
    bat['SOH0'] = cp.Parameter(1, name="SOH0", nonneg=True)
    bat['Tk0']  = cp.Parameter(1, name="Tk0", nonneg=True)
      
    # AC-side variables: 
    bat['AC_Pch']    = bat['Pch']/eta_ch
    bat['AC_Pdisch'] = bat['Pdisch'] * eta_dc
    bat['AC_Pnett']  = bat['AC_Pch'] - bat['AC_Pdisch']
    
    
    # Arbitrage variables:
    bat['c_kWh'] = cp.Parameter(Nh, name="c_kWh", nonneg=True)
      
    # Constraints:
    constr += [ 0 <= bat['Ebatt'][1:]]
    constr += [ bat['Ebatt'][1:] <= Enom * bat['SOH0']]
    constr += [ bat['Ebatt'][0]  == bat['E0'] ]
    constr += [ bat['Ebatt'][1:] == bat['Ebatt'][:-1] + dt*bat['Pnett'] ]
    constr += [ bat['SOC'] == bat['Ebatt']/(Enom * bat['SOH0'])]
    
    constr += [  0 <= bat['rate_ch'], bat['rate_ch'] <= Cr_ch ] 
    constr += [  0 <= bat['rate_dc'], bat['rate_dc'] <= Cr_dc ] 
      
    for i in range(settings['Qloss_cyc_Ab_ch'].shape[0]):
        constr += [ bat['Qloss_cyc_ch_per_h'] >= (settings['Qloss_cyc_Ab_ch'][i,0] * bat['rate_ch'] + settings['Qloss_cyc_Ab_ch'][i,1]) ]
    
    for i in range(settings['Qloss_cal'].shape[0]):
        constr += [ bat['Qloss_cal_per_h'] >= (settings['Qloss_cal'][i,0] + settings['Qloss_cal'][i,1]*bat['SOCavg'] + settings['Qloss_cal'][i,2]*bat['Tk_avg']) ]
    
    # Temperature model: k*((Tk-Tamb)*alpha + Qcell)
    constr += [ bat['Tk'][0] == bat['Tk0']]
    constr += [ bat['Tk'][1:] == bat['Tk'][:-1] + 3600*dt*bat['dTk']]        
    
    # constr += [bat['Pch'] == np.array([  0.        ,   0.        ,  75.80712788,  75.80712788,
    #        121.57809984,   0.        ,   0.        ,  41.24909223,
    #        121.57809984,  67.57280793,   0.        ,   0.        ,
    #        101.68350168, 121.57809984,   0.        ,   0.        ])]
    # constr += [bat['Pdisch'] == np.array([  0.        ,   0.        ,   0.        ,   0.        ,
    #          0.        , 230.4       ,  42.7923556 ,   0.        ,
    #          0.        ,   0.        ,   0.        , 230.4       ,
    #          0.        ,   0.        , 223.26160152,   0.        ])]                
                     
    # objective:
    bat['Qloss_cyc_dc']     = bat['dFEC']*settings['Qloss_cyc_dc']
    bat['Qloss_cyc_ch']     = bat['Qloss_cyc_ch_per_h']*dt
    bat['Qloss_cyc']        = bat['Qloss_cyc_dc'] + bat['Qloss_cyc_ch']
    bat['Qloss_cal']        = bat['Qloss_cal_per_h']*dt
    bat['Qloss']            = bat['Qloss_cyc']  + bat['Qloss_cal']
    
    bat['Qloss_lambda']     = settings['lambda_cal']*bat['Qloss_cal'] + settings['lambda_cyc']*bat['Qloss_cyc']
    bat['revenue']          = -dt*cp.multiply(bat['c_kWh'], bat['AC_Pnett'])
    
    bat['J_ageing_lambda']  = cost_whole*cp.sum(bat['Qloss_lambda'])
    bat['J_revenue']        = -cp.sum(bat['revenue'])  # Negative revenue
    bat['J']                = bat['J_revenue'] + bat['J_ageing_lambda']
          
    prob = cp.Problem(cp.Minimize(bat['J']), constr)
    
    solution = {key: np.array([]) for key in bat.keys()}
    
    indices = np.arange(Nh,dtype=np.int64)
    
    solution['settings'] = settings
    
    while(SOH0 >= settings['EOL']):
        print('Now SOH is: ', SOH0)
        # set initial values: 
        bat['c_kWh'].value = idc[indices] 
        bat['E0'].value = np.array([max(E0,0)])
        bat['SOH0'].value = np.array([SOH0])
        bat['Tk0'].value  = np.array([Tk0])
        
        try:
            prob.solve(solver=cp.GUROBI, verbose=False, warm_start=True, NumericFocus=3, FeasibilityTol=1e-9, OptimalityTol=1e-9)
        except: # This is added because there was a numeric problem with Gurobi
            prob.solve(solver=cp.SCIPY, scipy_options={"method": "highs",'options':{'tol':1e-10, 'autoscale':True}}, verbose=True)
     #   print("bat['AC_Pnett'] : ", bat['AC_Pnett'].value, '\n')

        for key in bat.keys():
            if(bat[key].value.size==Nh+1):
                solution[key] = np.concatenate((solution[key], bat[key].value[1:Nc+1]))
            elif(bat[key].value.size==Nh):
                solution[key] = np.concatenate((solution[key], bat[key].value[:Nc]))
        
        # refresh initial values:
        E0    = bat['Ebatt'].value[Nc]
        Tk0   = bat['Tk'].value[Nc]
        SOH0 -= np.sum(bat['Qloss'].value[:Nc])
        indices += Nc
        indices %= idc.size # Loop through 
        
    return solution