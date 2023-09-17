# -*- coding: utf-8 -*-
"""
Created on Sun Sep 17 04:32:24 2023

@author: Volkan Kumtepeli
"""
import numpy as np

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
def_settings = {'AC_eta_ch': 0.95, # charge eff of power electronics
            'AC_eta_dc': 0.95, # discharge eff of power electronics
            'bat_eta_ch': 0.95, # charge eff of battery
            'bat_eta_dc': 0.95, # discharge eff of battery
            'dataName': 'idc_positive_dummy.csv',
            'studyName': 'opportunity_hypothesis_2023_09_09',
            'horizon': 24*7, # horizon [h]
            'control-horizon' : 24,
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
