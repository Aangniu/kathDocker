fout=open('Nepal_rho_mu_lambda_Qs_Qp_dam.yaml', 'w')

# Note that we use a moment tensor definition that differs with the standards in Seismology (e.g. Komatitsch and Tromp, 1999).
# the moment tensor is opposite to the usual definition

# Note that strike, dip and rake allow rotating the seismic moment tensor.
# Typically, the moment tensor does not need to be rotated and strike = dip = rake = 0.

# With velocity component, a single force supposed to be defined

header=\
"""!Switch
[rho, mu0, lambda0, gammaR, xi0, mu, lambda, gamma, epsxx_alpha, epsyy_alpha, epszz_alpha, epsxy_alpha, epsyz_alpha, epszx_alpha, Cd, Qp, Qs]: !Any
  components:
    - !GroupFilter
      groups: 1
      components: !ConstantMap
        map:
          rho:    1400
          mu0:     56000000
          lambda0: 14000000
"""

tails=\
"""          xi0:    1.0
          mu:    56000000
          lambda: 14000000
          gamma:  0.0
          epsxx_alpha: -0.00
          epsyy_alpha: -0.00
          epszz_alpha: -0.00
          epsxy_alpha: 0.00
          epsyz_alpha: 0.00
          epszx_alpha: 0.00
          Cd: 10.0
          Qp: 20
          Qs: 10
    - !GroupFilter
      groups: 2
      components: !ConstantMap
        map:
          rho:    2700
          mu0:    28518750000
          lambda0: 24637500000
          gammaR: 1000000000000000000000000000000
          xi0:    1.0
          mu:     28518750000
          lambda: 24637500000
          gamma:  0.0
          epsxx_alpha: -0.0
          epsyy_alpha: -0.0
          epszz_alpha: -0.0
          epsxy_alpha: 0.0
          epsyz_alpha: 0.0
          epszx_alpha: 0.0
          Cd:     1.0
          Qp: 325
          Qs: 162.5
    - !GroupFilter
      groups: 3
      components: !ConstantMap
        map:
          rho:    2700
          mu0:    34992000000
          lambda0: 11739000000
          gammaR: 1000000000000000000000000000000
          xi0:    1.0
          mu:     34992000000
          lambda: 11739000000
          gamma:  0.0
          epsxx_alpha: -0.0
          epsyy_alpha: -0.0
          epszz_alpha: -0.0
          epsxy_alpha: 0.0
          epsyz_alpha: 0.0
          epszx_alpha: 0.0
          Cd: 1.0
          Qp: 360
          Qs: 180
    - !GroupFilter
      groups: 4
      components: !ConstantMap
        map:
          rho:    2900
          mu0:    37584000000
          lambda0: 32741000000
          gammaR: 1000000000000000000000000000000
          xi0:    1.0
          mu:     37584000000
          lambda: 32741000000
          gamma:  0.0
          epsxx_alpha: -0.0
          epsyy_alpha: -0.0
          epszz_alpha: -0.0
          epsxy_alpha: 0.0
          epsyz_alpha: 0.0
          epszx_alpha: 0.0
          Cd: 1.0
          Qp: 360
          Qs: 180
    - !GroupFilter
      groups: 5
      components: !ConstantMap
        map:
          rho:    3300
          mu0:     66825000000
          lambda0: 82863000000
          gammaR: 1000000000000000000000000000000
          xi0:    1.0
          mu:    66825000000
          lambda: 82863000000
          gamma:  0.0
          epsxx_alpha: -0.0
          epsyy_alpha: -0.0
          epszz_alpha: -0.0
          epsxy_alpha: 0.0
          epsyz_alpha: 0.0
          epszx_alpha: 0.0
          Cd: 1.0
          Qp: 450
          Qs: 225
"""

fout.write(header)

import numpy as np
from matplotlib import pyplot as plt

val = np.genfromtxt("in.txt")
print(val)

name_lists = ["          gammaR: "]

val_lists = [str(val[0])]

for i_e in range(1):
    entry = name_lists[i_e] + val_lists[i_e]
    print(name_lists[i_e] + val_lists[i_e])
    np.savetxt(fout, [entry], fmt="%s")

# np.savetxt(fout, name_lists[i_e] + val_lists[i_e])
fout.write(tails)

fout.close()
print('done writing Nepal_rho_mu_lambda_Qs_Qp_dam.yaml')