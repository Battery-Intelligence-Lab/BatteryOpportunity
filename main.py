import cvxpy as cp
import numpy as np
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

def solve_optimisation(settings):
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
    bat['Pch'] = cp.Variable(Nh)
    bat['Pdisch'] = cp.Variable(Nh)
    bat['Pnett']  = bat['Pch'] - bat['Pdisch']
    bat['Pabs']   = bat['Pch'] + bat['Pdisch']
    bat['rate_ch'] = bat['Pch'] / Enom
    bat['rate_dc'] = bat['Pdisch'] / Enom
    
    bat['Ebatt'] = cp.Variable(Nh+1) # Energy inside bat kWh
    bat['SOC'] = cp.Variable(Nh+1)
    bat['SOCavg'] = (bat['SOC'][1:] + bat['SOC'][:-1])/2.0
    bat['dFEC'] = 0.5*dt*bat['Pabs']/Enom # FEC per time step. 
      
      
    # Temperature model: 
    bat['Tk'] = cp.Variable(Nh+1)
    bat['Tk_avg'] = (bat['Tk'][1:] + bat['Tk'][:-1])/2.0
    bat['Qcell'] = settings['Qcell_ch']*bat['rate_ch'] + settings['Qcell_dc']*bat['rate_dc'] 
    bat['dTk'] = settings['k_Tcell']*((settings['Tamb'] - bat['Tk'][:-1])*settings['alpha_Tcell'] + bat['Qcell'])
    bat['Tc'] = bat['Tk'] - KELVIN
    
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
        constr += [ bat['Qloss_cyc_ch_per_h'] >= settings['Qloss_cyc_Ab_ch'][i,0] * bat['rate_ch'] + settings['Qloss_cyc_Ab_ch'][i,1] ]
    
    for i in range(settings['Qloss_cal'].shape[0]):
        constr += [ bat['Qloss_cal_per_h'] >= settings['Qloss_cal'][i,0] + settings['Qloss_cal'][i,1]*bat['SOCavg'] + settings['Qloss_cal'][i,2]*bat['Tk_avg'] ]
    
    # Temperature model: k*((Tk-Tamb)*alpha + Qcell)
    constr += [ bat['Tk'][0] == bat['Tk0']]
    constr += [ bat['Tk'][1:] == bat['Tk'][:-1] + 3600*dt*bat['dTk']]                        
                      
    
    # objective:
    bat['Qloss_cyc_dc']     = bat['dFEC']*settings['Qloss_cyc_dc']
    bat['Qloss_cyc_ch']     = bat['Qloss_cyc_ch_per_h']*dt
    bat['Qloss_cyc']        = bat['Qloss_cyc_dc'] + bat['Qloss_cyc_ch']
    bat['Qloss_cal']        = bat['Qloss_cal_per_h']*dt
    bat['Qloss']            = bat['Qloss_cyc']  + bat['Qloss_cal']
    
    bat['Qloss_lambda']     = settings['lambda_cyc']*bat['Qloss_cyc'] + settings['lambda_cal']*bat['Qloss_cal']
    bat['revenue']          = -dt*bat['c_kWh']*bat['AC_Pnett']
    
    bat['J_ageing_lambda']  = cost_whole*cp.sum(bat['Qloss_lambda'])
    bat['J_revenue']        = -cp.sum(bat['revenue'])  # Negative revenue
    bat['J'] = bat['J_revenue'] + bat['J_ageing_lambda']
          
    prob = cp.Problem(cp.Minimize(bat['J']), constr)
    
    solution = {key: np.array([]) for key in bat.keys()}
    while(SOH0 >= 0.998):
        print('Now SOH is: ', SOH0)
        # set initial values: 
        bat['c_kWh'].value = idc[:Nh] 
        bat['E0'].value = np.array([E0])
        bat['SOH0'].value = np.array([SOH0])
        bat['Tk0'].value  = np.array([Tk0])
        
        prob.solve(solver=cp.GUROBI, verbose=False, warm_start=True)
        
        # refresh initial values:
        E0    = bat['Ebatt'].value[Nc]
        Tk0   = bat['Tk'].value[Nc]
        SOH0 -= np.sum(bat['Qloss'].value[:Nc])
        
        for key in solution.keys():
            if(bat[key].value.size==Nh+1):
                solution[key] = np.concatenate((solution[key], bat[key].value[1:Nc+1]))
            elif(bat[key].value.size==Nh):
                solution[key] = np.concatenate((solution[key], bat[key].value[:Nc]))       
        
    return solution
    

start_time = time.time()

sol = solve_optimisation(settings)

end_time = time.time()
elapsed_time = end_time - start_time

print(f"Elapsed time: {elapsed_time} seconds")

    
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