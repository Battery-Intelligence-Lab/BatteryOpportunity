# -*- coding: utf-8 -*-
"""
Created on Mon Sep 18 05:10:52 2023
At each step solves an outer optimisation problem to update lambda

@author: engs2321
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

folder_name = 'results/bilevel_lambda_2023_09_18'
