# -*- coding: utf-8 -*-
"""
Created on Tue Sep 12 01:26:54 2023

Testing if gurobipy is faster as cvxpy is taking lots of time to process the problem!
Moreover it is processing problem at each time step! 

@author: engs2321
"""

import cvxpy as cp
import numpy as np
import gurobipy as gp
from gurobipy import GRB
import matplotlib.pyplot as plt
import time

KELVIN = 273.15 

cyc_ag_ch = np.genfromtxt('data/cyc_ageing_ch.csv', delimiter=",")

#cal ageing: 
# func.k_cal(0,18+KELVIN) = 4.3027e-05
# func.k_cal(1,18+KELVIN) = 5.6590e-04
# func.k_cal(0,60+KELVIN) = 1.2575e-04
# func.k_cal(1,60+KELVIN) = 1.6539e-03
# lets do two planes:
    # (i) [func.k_cal(0,18+KELVIN), func.k_cal(1,18+KELVIN), func.k_cal(0,60+KELVIN)]
    # (ii) [func.k_cal(1,18+KELVIN), func.k_cal(0,60+KELVIN), func.k_cal(1,60+KELVIN)]
    
    # Results from fitting:  f(SOC, Tk) = a + b*SOC + c*Tk
        # (i)  a,b,c = [-5.3041e-04,   5.2287e-04,  1.9696e-06]
        # (ii) a,b,c = [-85.0423e-04,  15.2813e-04, 2.5904e-05]

# We divide by 8 because of the square-root effect, it is too much! 
cal_ag = np.genfromtxt('data/cal_ageing_discounted.csv', delimiter=",")
 
# Settings: 
settings = {'AC_eta_ch': 0.95, # charge eff of power electronics
            'AC_eta_dc': 0.95, # discharge eff of power electronics
            'bat_eta_ch': 0.95, # charge eff of battery
            'bat_eta_dc': 0.95, # discharge eff of battery
            'dataName': 'idc_positive_dummy.csv',
            'studyName': 'opportunity_hypothesis_2023_09_09',
            'horizon': 4, # horizon [h]
            'control-horizon' : 1,
            'duration': 24*365*100, # 100 years
            'C-rate': [1.0, 1.2], # C-rate for charge and discharge
            'lambda_cal': 1.0,
            'lambda_cyc': 1.0,
            'dt' : 0.25, 
            'EOL': 0.8,
            'price_kWhcap' : 250,
            'Enom' : 24*8,  # kWh
            'SOCmin': 0.0, 
            'SOCmax': 1.0,
            # very initial values: 
            'Tamb' : 18 + KELVIN, # Ambient temperature
            'Tk0'  : KELVIN + 18,
            'E0'   : 0.0,
            'SOH0' : 1.0,
            'FEC0' : 0.0,
            # PWA
            'Qloss_cyc_Ab_ch' : cyc_ag_ch, # A_ch * rate_ch , b_ch [dSOH/hr/rate]
            'Qloss_cyc_dc' : 3.18e-7,   # per total FEC
            'Qloss_cal' : cal_ag, # Calendar ageing PWA
            # Temperature model: k*((Tk-Tamb)*alpha + Qcell)
            'k_Tcell': 0.014, # (1/(param.m_cell*param.c_p_cell))
            'alpha_Tcell': 0.0192, # param.cell.alpha.fan_100*param.A_cell
            # normally below numbers should be quadratic but considering now linear
            'Qcell_ch': 0.575, # Qcell / C-rate -> func.dQcell( 3,0.5,KELVIN+25)
            'Qcell_dc': 0.410, # Qcell / C-rate -> func.dQcell(-3,0.5,KELVIN+25)
            }

#def solve_optimisation(settings):
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

Qloss_cyc_Ab_ch = settings['Qloss_cyc_Ab_ch']
Qloss_cal = settings['Qloss_cal']


# Create a new model
m = gp.Model("battery_optimisation")
m.setParam("NumericFocus", 3)
m.setParam('FeasibilityTol', 1e-9)
m.setParam('OptimalityTol', 1e-9)

# Battery variables:
bat = {}
bat['Pch']    = m.addMVar(Nh, lb=0, ub=(Cr_ch*Enom), name="Pch")
bat['Pdisch'] = m.addMVar(Nh, lb=0, ub=(Cr_dc*Enom), name="Pdisch")
bat['Pnett']  = bat['Pch'] - bat['Pdisch']
bat['Pabs']   = bat['Pch'] + bat['Pdisch']

bat['Ebatt'] = m.addMVar(Nh+1, lb=0, ub=Enom, name="Ebatt") # Energy inside bat kWh
bat['SOC']   = m.addMVar(Nh+1, lb=0, ub=1, name="SOC")
bat['SOCavg'] = (bat['SOC'][1:] + bat['SOC'][:-1])/2.0
bat['dFEC'] = 0.5*dt*bat['Pabs']/Enom # FEC per time step. 
  
  
# Temperature model: 
bat['Tk']     = m.addMVar(Nh+1, lb=KELVIN, name="Tk")
bat['Tk_avg'] = (bat['Tk'][1:] + bat['Tk'][:-1])/2.0
bat['Qcell']  = settings['Qcell_ch']*bat['Pch'] / Enom + settings['Qcell_dc']*bat['Pdisch'] / Enom
bat['dTk']    = settings['k_Tcell']*((settings['Tamb'] - bat['Tk'][:-1])*settings['alpha_Tcell'] + bat['Qcell'])
bat['Tc']     = bat['Tk'] - KELVIN

# ageing params: 
bat['Qloss_cyc_ch_per_h'] = m.addMVar(Nh, lb=0, name="Qloss_cyc_ch_per_h") # Qloss cycle charging
bat['Qloss_cal_per_h']    = m.addMVar(Nh, lb=0, name="Qloss_cal_per_h") # Qloss calendar

# AC-side variables: 
bat['AC_Pch']    = bat['Pch']/eta_ch
bat['AC_Pdisch'] = bat['Pdisch'] * eta_dc
bat['AC_Pnett']  = bat['AC_Pch'] - bat['AC_Pdisch']


# Constraints:
constr = {}
constr['Ebatt_ub']     = m.addConstr(bat['Ebatt'][1:] <= Enom * SOH0)
constr['Ebatt_init']   = m.addConstr(bat['Ebatt'][0]  == E0)
constr['Ebatt_update'] = m.addConstr(bat['Ebatt'][1:] == bat['Ebatt'][:-1] + dt*bat['Pnett'])

constr['SOC_update']   = m.addConstr(bat['SOC'] == bat['Ebatt']/(Enom)) # #TODO add SOH0

for i in range(Qloss_cyc_Ab_ch.shape[0]): 
    m.addConstr(bat['Qloss_cyc_ch_per_h'] >= Qloss_cyc_Ab_ch[i,0] * bat['Pch']/Enom + Qloss_cyc_Ab_ch[i,1])


for i in range(settings['Qloss_cal'].shape[0]): 
    m.addConstr(bat['Qloss_cal_per_h'] >= (Qloss_cal[i,0] + Qloss_cal[i,1]*bat['SOCavg'] + Qloss_cal[i,2]*bat['Tk_avg'])) 
 

# Temperature model: k*((Tk-Tamb)*alpha + Qcell)
constr['Tk_init']   = m.addConstr(bat['Tk'][0] == Tk0)
constr['Tk_update'] = m.addConstr(bat['Tk'][1:] == bat['Tk'][:-1] + 3600*dt*bat['dTk'])                      


# m.addConstr(bat['Pch'] == np.array([  0.        ,   0.        ,  75.80712788,  75.80712788,
#        121.57809984,   0.        ,   0.        ,  41.24909223,
#        121.57809984,  67.57280793,   0.        ,   0.        ,
#        101.68350168, 121.57809984,   0.        ,   0.        ]))

# m.addConstr(bat['Pdisch'] == np.array([  0.        ,   0.        ,   0.        ,   0.        ,
#          0.        , 230.4       ,  42.7923556 ,   0.        ,
#          0.        ,   0.        ,   0.        , 230.4       ,
#          0.        ,   0.        , 223.26160152,   0.        ]))


# infeasible_Pch = np.array([  0.        ,   0.        , 111.42766698, 111.42766698,
#         111.42766698,   0.        ,   0.        , 111.42766698,
#         111.42766698, 111.42766698,   0.        ,   0.        ,
#         118.97233302, 111.42766698,   0.        ,   0.        ])

# infeasible_Pdisch = np.array([  0.        ,   0.        ,   0.        ,   0.        ,
#          0.        , 230.4       , 103.88300095,   0.        ,
#          0.        ,   0.        , 103.88300095, 230.4       ,
#          0.        ,   0.        , 230.4       ,   0.        ])

# infeasible_Pnett = infeasible_Pch - infeasible_Pdisch

# infeasible_Ebatt = np.cumsum(infeasible_Pnett*dt)

m.addConstr(bat['Pch'] == np.array([  0.00000005 ,   0.        , 111.42766698, 111.42766698,
        111.42766698,   0.        ,   0.        , 111.42766698,
        111.42766698, 111.42766698,   0.        ,   0.        ,
        118.97233302, 111.42766698,   0.        ,   0.        ]))


m.addConstr(bat['Pdisch'] == np.array([  0.        ,   0.        ,   0.        ,   0.        ,
         0.        , 230.4       , 103.88300095,   0.        ,
         0.        ,   0.        , 103.88300095, 230.4       ,
         0.        ,   0.        , 230.4       ,   0.        ]) )


bat['c_kWh'] = idc[:Nh]

# objective:
bat['Qloss_cyc_dc']     = bat['dFEC']*settings['Qloss_cyc_dc']
bat['Qloss_cyc_ch']     = bat['Qloss_cyc_ch_per_h']*dt
bat['Qloss_cyc']        = bat['Qloss_cyc_dc'] + bat['Qloss_cyc_ch']
bat['Qloss_cal']        = bat['Qloss_cal_per_h']*dt
bat['Qloss']            = bat['Qloss_cyc']  + bat['Qloss_cal']

bat['Qloss_lambda']     = settings['lambda_cal']*bat['Qloss_cal'] + settings['lambda_cyc']*bat['Qloss_cyc'] 
bat['revenue']          = -dt*bat['c_kWh']*bat['AC_Pnett']

bat['J_ageing_lambda']  = cost_whole*bat['Qloss_lambda'].sum()
bat['J_revenue']        = -bat['revenue'].sum()  # Negative revenue
bat['J']                = bat['J_revenue'] + bat['J_ageing_lambda']

m.setObjective(bat['J'], GRB.MINIMIZE)
  
# prob = cp.Problem(cp.Minimize(bat['J']), constr)
start_time = time.time()

m.optimize()

end_time = time.time()
elapsed_time = end_time - start_time

print(f"Elapsed time: {elapsed_time} seconds")

print("bat['AC_Pnett'] : ", bat['AC_Pnett'].getValue(), '\n')
print("bat['Pnett'] : ", bat['Pnett'].getValue(), '\n')
print("bat['Pch']*bat['Pdisch'] : ", bat['Pch'].X *  bat['Pdisch'].X, '\n')

print("bat['Ebatt'] : ", bat['Ebatt'].X, '\n')
print("bat['SOC'] : ", bat['SOC'].X, '\n')
print("max['SOC'] : ", np.max(bat['SOC'].X), '\n')
print("bat['SOCavg'] : ", bat['SOCavg'].getValue(), '\n')
print("bat['FEC'] : ", np.cumsum(bat['dFEC'].getValue()), '\n')
print("bat['Tk'] : ",  bat['Tk'].X, '\n')
print("bat['Tk_avg'] : ",  bat['Tk_avg'].getValue(), '\n')
print("bat['Tc'] : ",  bat['Tc'].getValue(), '\n')
print("Jcal total: ", bat['Qloss_cal'].getValue(), '\n')
print("Jcyc total: ", bat['Qloss_cyc'].getValue(), '\n')

solution = {key: np.array([]) for key in bat.keys()}
 # while(SOH0 >= 0.999):
 #     print('Now SOH is: ', SOH0)
 #     # set initial values: 
 #     bat['c_kWh'].value = idc[:Nh] 
 #     bat['E0'].value = np.array([E0])
 #     bat['SOH0'].value = np.array([SOH0])
 #     bat['Tk0'].value  = np.array([Tk0])
 
 #     prob.solve(solver=cp.GUROBI, verbose=False, warm_start=True)
 
 #     # refresh initial values:
 #     E0    = bat['Ebatt'].value[Nc]
 #     Tk0   = bat['Tk'].value[Nc]
 #     SOH0 -= np.sum(bat['Qloss'].value[:Nc])
 
 #     for key in solution.keys():
 #         if(bat[key].value.size==Nh+1):
 #             solution[key] = np.concatenate((solution[key], bat[key].value[1:Nc+1]))
 #         elif(bat[key].value.size==Nh):
 #             solution[key] = np.concatenate((solution[key], bat[key].value[:Nc]))       
        
  #  return solution
    



    
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
    # print("Jcal total: ", bat['Qloss_cal_tot'].value, '\n')
    # print("Jcyc total: ", bat['Qloss_cyc_tot'].value, '\n')
    # print("J_revenue :", J_revenue.value, '\n')