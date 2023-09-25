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
from sklearn.linear_model import LinearRegression

KELVIN = 273.15 


def get_horizons(settings):
    dt = settings['dt']
    Nh = int(settings['horizon']/dt)
    Nc = int(settings['control-horizon']/dt)
    return dt, Nh, Nc

def create_problem(settings):
    dt, Nh, Nc = get_horizons(settings)
    
    bat_eta_ch, bat_eta_dc  = settings['bat_eta_ch'], settings['bat_eta_dc']
    AC_eta_ch,  AC_eta_dc   = settings['AC_eta_ch'],  settings['AC_eta_dc']
    eta_ch,     eta_dc      = bat_eta_ch*AC_eta_ch,   bat_eta_dc*AC_eta_dc
    
    EOL = settings['EOL']
    Enom =  settings['Enom']
    cost_whole = Enom * settings['price_kWhcap'] / (1.0 - EOL)
    Cr_ch, Cr_dc = settings['C-rate'][0], settings['C-rate'][1]
      
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
    bat['lambda_cal'] = cp.Parameter(1, name="Tk0", nonneg=True)
    bat['lambda_cyc'] = cp.Parameter(1, name="Tk0", nonneg=True)
      
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
               
                     
    # objective:
    bat['Qloss_cyc_dc']     = bat['dFEC']*settings['Qloss_cyc_dc']
    bat['Qloss_cyc_ch']     = bat['Qloss_cyc_ch_per_h']*dt
    bat['Qloss_cyc']        = bat['Qloss_cyc_dc'] + bat['Qloss_cyc_ch']
    bat['Qloss_cal']        = bat['Qloss_cal_per_h']*dt
    bat['Qloss']            = bat['Qloss_cyc']  + bat['Qloss_cal']
    
    bat['Qloss_lambda']     = bat['lambda_cal']*bat['Qloss_cal'] + bat['lambda_cyc']*bat['Qloss_cyc']
    bat['revenue']          = -dt*cp.multiply(bat['c_kWh'], bat['AC_Pnett'])
    
    bat['J_ageing_lambda']  = cost_whole*cp.sum(bat['Qloss_lambda'])
    bat['J_revenue']        = -cp.sum(bat['revenue'])  # Negative revenue
    bat['J']                = bat['J_revenue'] + bat['J_ageing_lambda']
          
    
    bat['lambda_cal'].value = np.array([settings['lambda_cal']])
    bat['lambda_cyc'].value = np.array([settings['lambda_cyc']])
    
    return bat, constr

def solve(prob):
   try:
       prob.solve(solver=cp.GUROBI, verbose=False, warm_start=True, NumericFocus=3, FeasibilityTol=1e-9, OptimalityTol=1e-9)
   except: # This is added because there was a numeric problem with Gurobi
       prob.solve(solver=cp.SCIPY, scipy_options={"method": "highs",'options':{'tol':1e-10, 'autoscale':True}}, verbose=True)

def update_solution(solution, bat, settings):
    dt, Nh, Nc = get_horizons(settings)
    for key in bat.keys():
        if(bat[key].value.size==Nh+1):
            solution[key] = np.concatenate((solution[key], bat[key].value[1:Nc+1]))
        elif(bat[key].value.size==Nh):
            solution[key] = np.concatenate((solution[key], bat[key].value[:Nc]))
    
    for key in ['lambda_cal', 'lambda_cyc']:
        solution[key] = np.concatenate((solution[key], bat[key].value))        
        
def set_initial_values(bat, settings):
    bat['Tk0'].value   = np.full(1, settings['Tk0'])
    bat['E0'].value    = np.full(1, settings['E0']) 
    bat['SOH0'].value  = np.full(1, settings['SOH0'])    

def solve_optimisation(settings):
    dt, Nh, Nc = get_horizons(settings)
    idc = np.genfromtxt('data/' + settings['dataName'])
    
    bat, constr = create_problem(settings)
    
    prob = cp.Problem(cp.Minimize(bat['J']), constr)
    
    solution = {key: np.array([]) for key in bat.keys()}
    solution['settings'] = settings
    
    indices = np.arange(Nh,dtype=np.int64) % idc.size # For simulations with Nh longer than idc.size
       
    bat['c_kWh'].value = idc[indices]
    set_initial_values(bat, settings)

    while(bat['SOH0'].value >= settings['EOL']):
        print('Now SOH is: ', bat['SOH0'].value[0])
        
        solve(prob)
        update_solution(solution, bat, settings)
                
        # refresh initial values:
        indices = (indices + Nc) % idc.size # Loop through 
        bat['c_kWh'].value    = idc[indices] 
        bat['E0'].value[0]    = max(bat['Ebatt'].value[Nc], 0)
        bat['SOH0'].value[0] -= np.sum(bat['Qloss'].value[:Nc])
        bat['Tk0'].value[0]   = bat['Tk'].value[Nc]
        
    return solution

def revenue_per_Qloss(settings, print_SOH = True):
    dt, Nh, Nc = get_horizons(settings)
       
    idc = np.genfromtxt('data/' + settings['dataName'])
    
    bat, constr = create_problem(settings)
    
    prob = cp.Problem(cp.Minimize(bat['J']), constr)
    
    solution = {key: np.array([]) for key in bat.keys()}
    solution['settings'] = settings
    
    indices = np.arange(Nh,dtype=np.int64) % idc.size # For simulations with Nh longer than idc.size
    
    revenue_per_Qloss = 0 # a very small number. 
    is_increasing = True
    
    bat['c_kWh'].value = idc[indices]
    set_initial_values(bat,settings)

    while(bat['SOH0'].value >= settings['EOL']):
        print('Now SOH is: ', bat['SOH0'].value[0], 'lambda is: ', bat['lambda_cal'].value)
        solve(prob)
        update_solution(solution, bat, settings)
                
       # new_revenue_per_Qloss = -bat['J_revenue'].value/np.sum(bat['Qloss'].value)/(1 + np.sum(np.abs(np.diff(bat['c_kWh'].value))))
        new_revenue_per_Qloss = -bat['J_revenue'].value/np.sum(bat['Qloss'].value)/(0.001 + np.std(np.diff(bat['c_kWh'].value)/bat['c_kWh'].value[:-1])  )

        
       #    print(f"Revenue per loss {new_revenue_per_Qloss}")
        if(revenue_per_Qloss < new_revenue_per_Qloss):
            if(is_increasing):
                bat['lambda_cal'].value *= 1.05
                bat['lambda_cyc'].value *= 1.05
            else:
                bat['lambda_cal'].value *= 0.95
                bat['lambda_cyc'].value *= 0.95                    
        else:
            is_increasing = not is_increasing
            if(is_increasing):
                bat['lambda_cal'].value *= 1.05
                bat['lambda_cyc'].value *= 1.05
            else:
                bat['lambda_cal'].value *= 0.95
                bat['lambda_cyc'].value *= 0.95                 
               
                
            revenue_per_Qloss = new_revenue_per_Qloss
        
        # refresh initial values:
        indices = (indices + Nc) % idc.size # Loop through 
        bat['c_kWh'].value = idc[indices] 
        bat['E0'].value[0] = max(bat['Ebatt'].value[Nc], 0)
        bat['SOH0'].value[0] -= np.sum(bat['Qloss'].value[:Nc])
        bat['Tk0'].value[0] = bat['Tk'].value[Nc]


def moving_least_squares(settings):
    dt, Nh, Nc = get_horizons(settings)
    idc = np.genfromtxt('data/' + settings['dataName'])
    window = settings['window_length_d']
    
    bat, constr = create_problem(settings)
    
    prob = cp.Problem(cp.Minimize(bat['J']), constr)
    
    solution = {key: np.array([]) for key in bat.keys()}
    solution['settings'] = settings
    
    indices = np.arange(Nh,dtype=np.int64) % idc.size # For simulations with Nh longer than idc.size
       
    bat['c_kWh'].value = idc[indices]
    set_initial_values(bat, settings)
    
    Qtot = np.array([])
    reve = np.array([])
    
    cost_whole = settings['Enom'] * settings['price_kWhcap'] / (1.0 - settings['EOL'])
    
    while(bat['SOH0'].value >= settings['EOL']):
        print('Now SOH is: ', bat['SOH0'].value[0])
        
        solve(prob)
        update_solution(solution, bat, settings)
        
        if(Qtot.size == window):
            Qtot = np.delete(Qtot, 0)
            reve = np.delete(reve, 0)

        Qtot = np.append(Qtot, np.sum(bat['Qloss'].value))
        reve = np.append(reve, np.sum(bat['revenue'].value))        
                    
        lr = LinearRegression(positive=True, fit_intercept=(Qtot.size!=1))
        reg = lr.fit(cost_whole*Qtot.reshape(-1, 1), reve.reshape(-1, 1))
        
        print(f"Linear regression slope: {reg.coef_}, intercept: {reg.intercept_}")
        new_lambda = max(reg.coef_[0], 0.01)
        
        bat['lambda_cyc'].value[0] = new_lambda
        bat['lambda_cal'].value[0] = new_lambda
                
        # refresh initial values:
        indices = (indices + Nc) % idc.size # Loop through 
        bat['c_kWh'].value    = idc[indices] 
        bat['E0'].value[0]    = max(bat['Ebatt'].value[Nc], 0)
        bat['SOH0'].value[0] -= np.sum(bat['Qloss'].value[:Nc])
        bat['Tk0'].value[0]   = bat['Tk'].value[Nc]
        
    return solution


def moving_average_filter(settings):
    dt, Nh, Nc = get_horizons(settings)
    idc = np.genfromtxt('data/' + settings['dataName'])
    window = settings['window_length_d']
    
    bat, constr = create_problem(settings)
    
    prob = cp.Problem(cp.Minimize(bat['J']), constr)
    
    solution = {key: np.array([]) for key in bat.keys()}
    solution['settings'] = settings
    
    indices = np.arange(Nh,dtype=np.int64) % idc.size # For simulations with Nh longer than idc.size
       
    bat['c_kWh'].value = idc[indices]
    set_initial_values(bat, settings)
    
    reve_per_Qtot = np.array([])
    
    cost_whole = settings['Enom'] * settings['price_kWhcap'] / (1.0 - settings['EOL'])
    
    while(bat['SOH0'].value >= settings['EOL']):
        print('Now SOH is: ', bat['SOH0'].value[0], "lambda: ", bat['lambda_cyc'].value[0])
        
        solve(prob)
        update_solution(solution, bat, settings)
        
        if(reve_per_Qtot.size == window):
            reve_per_Qtot = np.delete(reve_per_Qtot, 0)

        reve_per_Qtot = np.append(reve_per_Qtot, max(0.01, np.sum(bat['revenue'].value)/np.sum(bat['Qloss'].value)/cost_whole))

        new_lambda = settings['meanFunction'](reve_per_Qtot);

        bat['lambda_cyc'].value[0] = new_lambda
        bat['lambda_cal'].value[0] = new_lambda
                
        # refresh initial values:
        indices = (indices + Nc) % idc.size # Loop through 
        bat['c_kWh'].value    = idc[indices] 
        bat['E0'].value[0]    = max(bat['Ebatt'].value[Nc], 0)
        bat['SOH0'].value[0] -= np.sum(bat['Qloss'].value[:Nc])
        bat['Tk0'].value[0]   = bat['Tk'].value[Nc]
        
    return solution

def simulate_and_save(settings, i_now, simFunction=solve_optimisation):
    os.makedirs(settings['folderName'], exist_ok=True)
    print(f"Starting {settings['studyName']}: {i_now}-th trial for lambda-cyc = {settings['lambda_cyc']}, lambda-cal = {settings['lambda_cal']}")
    start_time = time.time()
    sol = simFunction(settings)
    sio.savemat(settings['folderName']+"/" + settings['studyName'] + "_"+ str(i_now) +"_.mat", sol)
    end_time = time.time()
    elapsed_time = end_time - start_time
    print(f"Elapsed time: {elapsed_time} seconds")   