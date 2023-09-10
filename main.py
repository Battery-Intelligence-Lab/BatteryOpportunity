import cvxpy as cp
import numpy as np


KELVIN = 273.15 

cyc_ag_ch = np.genfromtxt('data/cyc_ageing_ch.csv', delimiter=",")



# Settings: 
settings = {'eta_ch': 0.95, # charge eff
            'eta_dc': 0.95, # discharge eff
            'dataName': 'idc_positive_dummy.csv',
            'studyName': 'opportunity_hypothesis_2023_09_09',
            'horizon': 8, # horizon [h]
            'C-rate': [1.0, 2.0], # C-rate for charge and discharge
            'lambda_cal': 1.0,
            'lambda_cyc': 1.0,
            'dt' : 0.25, 
            'EOL': 0.8,
            'price_kWhcap' : 250,
            'Enom' : 24*8,  # kWh
            'SOCmin': 0.0, 
            'SOCmax': 0.95,
            # very initial values: 
            'Tk' : KELVIN + 25,
            'E0' : 0.0,
            'SOH0' : 1.0,
            'FEC0' : 0.0,
            # PWA
            'Qloss_cyc_Ab_ch' : cyc_ag_ch, # A_ch * rate_ch , b_ch [dSOH/hr/rate]
            'Qloss_cyc_dc' : 3.18e-7   # per total FEC
            }

def solve_optimisation(settings):
    dt = settings['dt']
    Nh = int(settings['horizon']/dt)
    eta_ch = settings['eta_ch']
    eta_dc = settings['eta_dc']
    EOL = settings['EOL']
    Enom =  settings['Enom']
    cost_whole = Enom * settings['price_kWhcap'] / (1.0 - EOL)
    Cr_ch, Cr_dc = settings['C-rate'][0], settings['C-rate'][1]
    
    E0 = settings['E0']
    SOH0 = settings['SOH0']
    FEC0 = settings['FEC0']
    idc = np.genfromtxt('data/' + settings['dataName'])

    constr = []
      
    # Battery variables:
    bat = {}
    bat['Pch'] = cp.Variable(Nh)
    bat['Pdisch'] = cp.Variable(Nh)
    bat['Pnett'] = bat['Pch'] - bat['Pdisch']
    bat['Pgross'] = bat['Pch'] + bat['Pdisch']
    bat['rate_ch'] = bat['Pch'] / Enom
    bat['rate_dc'] = bat['Pdisch'] / Enom
    bat['Tk'] = cp.Variable(Nh+1)
    bat['Tk_avg'] = cp.Variable(Nh)
    bat['Ebatt'] = cp.Variable(Nh+1) # Energy inside bat kWh
    bat['FEC'] = cp.Variable(Nh+1)
    # ageing params: 
        
    bat['Qloss_cyc_ch'] = cp.Variable(Nh) # Qloss
    
    # initial params:
    bat['FEC0'] = cp.Parameter(1)
    bat['E0'] = cp.Parameter(1)
    bat['SOH0'] = cp.Parameter(1)
    
    # AC-side variables: 
    AC = {}
    AC['Pch'] = cp.Variable(Nh)
    AC['Pdisch'] = cp.Variable(Nh)
    AC['Pnett'] = AC['Pch'] - AC['Pdisch']
    

    # Arbitrage variables: 
    c_kWh = cp.Parameter(Nh)
    
    # Constraints:
    constr += [ bat['FEC'][0] == bat['FEC0']]
    constr += [ bat['FEC'][1:] == bat['FEC'][:-1] + 0.5*dt*bat['Pgross']/Enom ]

    
    constr += [ 0 <= bat['Ebatt'][1:]]
    constr += [ bat['Ebatt'][1:] <= Enom * bat['SOH0']]
    constr += [ bat['Ebatt'][0]  == bat['E0'] ]
    constr += [ bat['Ebatt'][1:] == bat['Ebatt'][:-1] + dt*bat['Pnett'] ]
    
    constr += [ bat['Pnett'] == eta_ch*AC['Pch'] - eta_dc*AC['Pdisch']  ]
    
    constr += [  0 <= bat['Pch'] ] 
    constr += [       bat['rate_ch'] <= Cr_dc] 
    
    
    constr += [  0 <= bat['Pdisch'] ] 
    constr += [       bat['rate_dc'] <= Cr_ch] 
    
    
    for i in range(Nh):
        constr += [ bat['Qloss_cyc_ch'][i] >= settings['Qloss_cyc_Ab_ch'][:,0] * bat['rate_ch'][i] + settings['Qloss_cyc_Ab_ch'][:,1] ]
    
    
    # objective: 
    J_ageing_cyc_dc = cost_whole*bat['FEC'][-1]*settings['Qloss_cyc_dc']
    J_ageing_cyc_ch = cost_whole*cp.sum(bat['Qloss_cyc_ch'])*dt
    J_ageing_cyc = J_ageing_cyc_ch +  J_ageing_cyc_dc
    
    J_revenue = dt*(c_kWh.T @ AC['Pnett'])  # Negative revenue
    
    J =  J_revenue + J_ageing_cyc
    
    
    # set initial values: 
    c_kWh.value = idc[:Nh] 
    bat['E0'].value = np.array([E0])
    bat['SOH0'].value = np.array([SOH0])
    bat['FEC0'].value = np.array([FEC0])
    
    prob = cp.Problem(cp.Minimize(J), constr)
    prob.solve(solver=cp.GUROBI, verbose=True)
    print("AC['Pnett'] : ", AC['Pnett'].value, '\n')
    print("bat['Pnett'] : ", bat['Pnett'].value, '\n')
    print("bat['Pch'] : ", bat['Pch'].value, '\n')
    print("bat['Pdisch'] : ", bat['Pdisch'].value, '\n')

    print("bat['Ebatt'] : ", bat['Ebatt'].value, '\n')
    print("bat['FEC'] : ", bat['FEC'].value, '\n')

    print('Prices: ', c_kWh.value, '\n')


solve_optimisation(settings)