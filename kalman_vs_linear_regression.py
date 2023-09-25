## pip install scikit-learn

import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression


# Load actual data: 
real_data = np.genfromtxt('estimation_example.csv',delimiter=',',names=True)
Qcal = real_data['Qcal']
Qcyc = real_data['Qcyc']
reve = real_data['Revenue']

Qtot = Qcal + Qcyc


c_investment = 250*192/0.2

# Generate sample data
np.random.seed(0)
n_samples = Qtot.size
ageing = Qtot
profit = reve

n_training = n_samples

# Linear Regression
X = c_investment*ageing.reshape(-1, 1)

lr = LinearRegression(positive=True,fit_intercept=(n_training!=1))
reg = lr.fit(X[:n_training], profit[:n_training])
profit_pred = lr.predict(X)

print(f"Linear regression slope: {reg.coef_}, intercept: {reg.intercept_}, score: {reg.score(X,profit)}")

class KalmanFilterLinearRegressionTwoMeasurements:
    def __init__(self, Q, R):
        self.F = np.eye(2)
        self.H = None
        self.Q = Q
        self.R = R
        self.P = np.eye(2)*0.001
        self.x = np.zeros(2)
        
    def predict(self):
        self.x = self.F @ self.x
        self.P = self.P + self.Q
        
    def update(self, x1, x2, y1, y2):
        self.H = np.array([[1, x1], [1, x2]])
        y_hat = self.H @ self.x
        y_tilde = np.array([y1, y2]).reshape(2,1) - y_hat
        S = self.H @ self.P @ self.H.T + self.R
        K = self.P @ self.H.T @ np.linalg.inv(S)
        self.x = self.x + K @ y_tilde
        self.P = (np.eye(2) - K @ self.H) @ self.P

    def fit(self, X, Y):
        for i in range(0, len(X), 2):
            self.predict()
            self.update(X[i], X[i+1], Y[i], Y[i+1])
        return self.x

    def predict_y(self, X):
        return [self.x[0] + self.x[1] * x_k for x_k in X]

# Kalman filter parameters
Q = np.eye(2) * 0.001
R = np.array([[1, 0], [0, 1]])

# Kalman filter with 2 measurements at a time
kf_lr_2_meas = KalmanFilterLinearRegressionTwoMeasurements(Q, R)
kf_lr_2_meas.fit(ageing, profit)
profit_kf_2_meas_pred = kf_lr_2_meas.predict_y(ageing)

# Plot
plt.figure(figsize=(12, 6))
plt.scatter(ageing, profit, label='True Data', color='blue', s=10)
plt.plot(ageing, profit_pred, label='Linear Regression', color='red')
plt.plot(ageing, profit_kf_2_meas_pred, label='Kalman Filter LR (2 measurements)', color='orange')
plt.xlabel('Battery Ageing')
plt.ylabel('Profit')
plt.title('Comparison: Linear Regression vs. Kalman Filter LR (2 measurements)')
plt.legend()
plt.grid(True)
plt.show()

