import cvxpy as cp
import numpy as np
import matplotlib.pyplot as plt

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
    
    bat_eta_ch, bat_eta_dc  = settings['bat_eta_ch'], settings['bat_eta_dc']
    AC_eta_ch,  AC_eta_dc   = settings['AC_eta_ch'],  settings['AC_eta_dc']
    eta_ch,     eta_dc      = bat_eta_ch*AC_eta_ch,   bat_eta_dc*AC_eta_dc
    
    EOL = settings['EOL']
    Enom =  settings['Enom']
    cost_whole = Enom * settings['price_kWhcap'] / (1.0 - EOL)
    Cr_ch, Cr_dc = settings['C-rate'][0], settings['C-rate'][1]
    
    E0 = settings['E0']
    SOH0 = settings['SOH0']
    FEC0 = settings['FEC0']
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
    bat['FEC'] = cp.Variable(Nh+1)
      
      
    # Temperature model: 
    bat['Tk'] = cp.Variable(Nh+1)
    bat['Tk_avg'] = (bat['Tk'][1:] + bat['Tk'][:-1])/2.0
    bat['Qcell'] = settings['Qcell_ch']*bat['rate_ch'] + settings['Qcell_dc']*bat['rate_dc'] 
    bat['dTk'] = settings['k_Tcell']*((settings['Tamb'] - bat['Tk'][:-1])*settings['alpha_Tcell'] + bat['Qcell'])
    bat['Tc'] = bat['Tk'] - KELVIN
    
    # ageing params: 
    bat['Qloss_cyc_ch'] = cp.Variable(Nh) # Qloss cycle charging
    bat['Qloss_cal']    = cp.Variable(Nh) # Qloss calendar
    
    # initial params:
    bat['FEC0'] = cp.Parameter(1)
    bat['E0']   = cp.Parameter(1)
    bat['SOH0'] = cp.Parameter(1)
    bat['Tk0']  = cp.Parameter(1)
      
    # AC-side variables: 
    AC = {}
    bat['AC_Pch']    = bat['Pch']/eta_ch
    bat['AC_Pdisch'] = bat['Pdisch'] * eta_dc
    bat['AC_Pnett']  = bat['AC_Pch'] - bat['AC_Pdisch']
    
    
    # Arbitrage variables: 
    c_kWh = cp.Parameter(Nh)
      
    # Constraints:
    constr += [ bat['FEC'][0] == bat['FEC0'],
    bat['FEC'][1:] == bat['FEC'][:-1] + 0.5*dt*bat['Pabs']/Enom ]
    
    constr += [ 0 <= bat['Ebatt'][1:]]
    constr += [ bat['Ebatt'][1:] <= Enom * bat['SOH0']]
    constr += [ bat['Ebatt'][0]  == bat['E0'] ]
    constr += [ bat['Ebatt'][1:] == bat['Ebatt'][:-1] + dt*bat['Pnett'] ]
    constr += [ bat['SOC'] == bat['Ebatt']/(Enom * bat['SOH0'])]
    
    constr += [  0 <= bat['rate_ch'], bat['rate_ch'] <= Cr_ch ] 
    constr += [  0 <= bat['rate_dc'], bat['rate_dc'] <= Cr_dc ] 
      
      
    for i in range(Nh):
        constr += [ bat['Qloss_cyc_ch'][i] >= settings['Qloss_cyc_Ab_ch'][:,0] * bat['rate_ch'][i] + settings['Qloss_cyc_Ab_ch'][:,1] ]
    
    for i in range(Nh):
        constr += [ bat['Qloss_cal'][i] >= settings['Qloss_cal'][:,0] + settings['Qloss_cal'][:,1]*bat['SOCavg'][i] + settings['Qloss_cal'][:,2]*bat['Tk_avg'][i] ]
    
    
    # Temperature model: k*((Tk-Tamb)*alpha + Qcell)
    constr += [ bat['Tk'][0] == bat['Tk0']]
    constr += [ bat['Tk'][1:] == bat['Tk'][:-1] + 3600*dt*bat['dTk']]                        
                      
    
    # objective: 
    bat['Qloss_cyc_dc_tot'] = bat['FEC'][-1]*settings['Qloss_cyc_dc']
    bat['Qloss_cyc_ch_tot'] = cp.sum(bat['Qloss_cyc_ch'])*dt
    bat['Qloss_cyc_tot']    = bat['Qloss_cyc_ch_tot'] + bat['Qloss_cyc_dc_tot']
    bat['Qloss_cal_tot']    = cp.sum(bat['Qloss_cal'])*dt
    bat['Qloss_tot']        = bat['Qloss_cyc_tot']  + bat['Qloss_cal_tot']
    
    
    J_ageing  = cost_whole*bat['Qloss_tot']
    J_revenue = dt*(c_kWh.T @ bat['AC_Pnett'])  # Negative revenue
    
    J = J_revenue + J_ageing
      
      
    # set initial values: 
    c_kWh.value = idc[:Nh] 
    bat['E0'].value = np.array([E0])
    bat['SOH0'].value = np.array([SOH0])
    bat['FEC0'].value = np.array([FEC0])
    bat['Tk0'].value  = np.array([Tk0])
    
    prob = cp.Problem(cp.Minimize(J), constr)
    prob.solve(solver=cp.GUROBI, verbose=True)
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
    plt.figure(figsize=(10, 6))
    plt.plot(bat['SOC'].value, label="AC['SOC'].value")
    plt.xlabel("Days")
    plt.ylabel("Aging")
    plt.title("Battery Aging over Time Approaching Expiration")
    plt.legend()
    plt.grid(True)
    plt.show()
    
    # print("bat['AC_Pnett'] : ", bat['AC_Pnett'].value, '\n')
    # print("bat['Pnett'] : ", bat['Pnett'].value, '\n')
    # print("bat['Pch']*bat['Pdisch'] : ", bat['Pch'].value *  bat['Pdisch'].value, '\n')
    
    # print("bat['Ebatt'] : ", bat['Ebatt'].value, '\n')
    # print("bat['SOC'] : ", bat['SOC'].value, '\n')
    # print("max['SOC'] : ", np.max(bat['SOC'].value), '\n')
    # print("bat['SOCavg'] : ", bat['SOCavg'].value, '\n')
    # print("bat['FEC'] : ", bat['FEC'].value, '\n')
    # print("bat['Tc'] : ",  bat['Tc'].value, '\n')
    # print("Jcal total: ", bat['Qloss_cal_tot'].value, '\n')
    # print("Jcyc total: ", bat['Qloss_cyc_tot'].value, '\n')
    # print("J_revenue :", J_revenue.value, '\n')


solve_optimisation(settings)