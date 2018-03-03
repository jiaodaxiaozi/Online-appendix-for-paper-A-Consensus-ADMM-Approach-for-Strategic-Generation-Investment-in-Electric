$ontext
A Consensus-ADMM Approach for Strategic Generation Investment in Electricity Markets
Copyright (C) 2017 Vladimir Dvorkin

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
$offtext
$eolcom //
option iterlim=999999999;     // avoid limit on iterations
option reslim=999999999;      // timelimit for solver in sec.
option optcr=0;               // gap tolerance
option solprint=off;          // include solution print in .lst file
option limrow=0;              // limit number of rows in .lst file
option limcol=0;              // limit number of columns in .lst file
option decimals=1;            // defines decimals in output file
option mip=cplex;
option MIQCP=cplex;
//--------------------------------------------------------------------

Sets
t        'time period'                                           /t1*t2/
h        'operating conditions'                                  /h1*h5/
k        'market scenarios'                                      /k1*k3/
gamma    'long-term scenarios'                                   /gamma1*gamma3/
e        'existing units'                                        /e1*e2/
e_g(e)   'existing conventional units'                           /e1/
e_w(e)   'existing wind units'                                   /e2/
c        'candidate units'                                       /c1*c3/
c_g(c)   'candidate conventional units'                          /c1*c2/
c_w(c)   'candidate wind units'                                  /c3*c3/
r        'rival units'                                           /r1*r5/
r_g(r)   'rival conventional units'                              /r2*r5/
r_w(r)   'rival wind units'                                      /r1*r1/
d        'demand units'                                          /d1*d1/
y        'SOS-1 set'                                             /y1*y2/
b        'Demand blocks'                                         /b1*b1/
PH_iter  'PH iteration counter'                                  /PH1*PH500/
;
Alias(t,tau);
Alias(gamma,gamma_pr);
Alias(k,k_pr);

***** Demand data

Parameter P_D_max_data(t,gamma,d,b)      'Actual power capacity of demand units';
P_D_max_data(t,gamma,d,b)=1050;
*P_D_max_data('t2',gamma,d,b)=P_D_max_data('t1',gamma,d,b)*1.1;
P_D_max_data('t2','gamma1',d,b)=P_D_max_data('t1','gamma1',d,b)*1.2;
P_D_max_data('t2','gamma2',d,b)=P_D_max_data('t1','gamma1',d,b)*1.0;
P_D_max_data('t2','gamma3',d,b)=P_D_max_data('t1','gamma1',d,b)*0.8;


Display P_D_max_data;

Parameter b_D_data(t,k,d,b)              'Utility of demand units';
b_D_data(t,k,d,'b1')=70;

***** Existing units of the strategic producer
Parameter X_E_max(e)                     'Power capacity of exisiting units';
X_E_max('e1')=100;
X_E_max('e2')=50;

Parameter C_E_data(t,gamma,e)            'Generating costs of existing units';
C_E_data(t,gamma,'e1')=35;
C_E_data(t,gamma,'e2')=0;

****** Rival units
Parameter P_R_max_data(t,gamma,r)        'Power capacity of rival units';
P_R_max_data(t,gamma,'r1')=50;
P_R_max_data(t,gamma,'r2')=800;
P_R_max_data(t,gamma,'r3')=100;
P_R_max_data(t,gamma,'r4')=100;
P_R_max_data(t,gamma,'r5')=300;

Parameter C_R_data(t,gamma,k,r)          'Generating costs of rival units';
C_R_data(t,gamma,k,'r1')=0;
C_R_data(t,gamma,k,'r2')=10;
C_R_data(t,gamma,k,'r3')=43;
C_R_data(t,gamma,k,'r4')=50;
C_R_data(t,gamma,k,'r5')=60;

C_R_data(t,gamma,'k2',r)=C_R_data(t,gamma,'k1',r)*1.1;
C_R_data(t,gamma,'k3',r)=C_R_data(t,gamma,'k1',r)*0.9;

Display C_R_data;

****** Investment data
Parameter X_C_max(c)                     'Power capacity of candidate units';
X_C_max(c)=500;

Parameter C_C_data(t,gamma,c)            'Generating costs of candidate units';
C_C_data(t,gamma,'c1')=40;
C_C_data(t,gamma,'c2')=33;
C_C_data(t,gamma,'c3')=0;

Parameter C_inv_data(t,gamma,c)          'Investment costs of candidate units';
C_inv_data(t,gamma,'c1')=600000;
C_inv_data(t,gamma,'c2')=800000;
C_inv_data(t,gamma,'c3')=1000000;

Display C_inv_data;

Parameter I_max(t)               'Investment budget';
I_max(t)=100000000;

****** Scenario conditions
Parameter pi_M(k)                'Probability of market scenarios';
pi_M(k)=1/card(k);

Parameter pi_L(gamma)            'Probability o flong-term scenarios';
pi_L(gamma)=1/card(gamma);
Display pi_L;

Parameter N_MC(h)                'Number of hours for each market conditions';
N_MC('h1')=1036*3;
N_MC('h2')=4306*3;
N_MC('h3')=443*3;
N_MC('h4')=955*3;
N_MC('h5')=2020*3;

Parameter K_CF_E(h,e_w)          'Capacity factor of existing wind power units';
K_CF_E('h1',e_w)=0.1223;
K_CF_E('h2',e_w)=0.1415;
K_CF_E('h3',e_w)=0.6968;
K_CF_E('h4',e_w)=0.1307;
K_CF_E('h5',e_w)=0.7671;

Parameter K_CF_R(h,r_w)          'Capacity factor of existing wind power units';
K_CF_R('h1',r_w)=0.1223;
K_CF_R('h2',r_w)=0.1415;
K_CF_R('h3',r_w)=0.6968;
K_CF_R('h4',r_w)=0.1307;
K_CF_R('h5',r_w)=0.7671;

Parameter K_CF_C(h,c_w)          'Capacity factor of candidate wind power units';
K_CF_C('h1',c_w)=0.1223;
K_CF_C('h2',c_w)=0.1415;
K_CF_C('h3',c_w)=0.6968;
K_CF_C('h4',c_w)=0.1307;
K_CF_C('h5',c_w)=0.7671;

Parameter K_DF(h)                'Demand factor';
K_DF(h)=1;


****** Non-anticipativity conditions
Parameter AM(t,gamma,k,gamma_pr,k_pr) 'non-anticipativity matrix';
AM(t,gamma,k,gamma_pr,k_pr)=0;
Loop((t,gamma,k,gamma_pr,k_pr),
         IF(ord(t)=1,
                 AM(t,gamma,k,gamma_pr,k_pr) = 1;
         );
         IF(ord(t)=2,
                 IF(ord(gamma)=ord(gamma_pr),
                         AM(t,gamma,k,gamma_pr,k_pr) = 1;
                 );

         );
);
Display AM;

Parameter Pr(t,gamma,k) 'Probability of an outcome at time period t';
Pr(t,gamma,k)=0;
Loop((t,gamma,k),
         IF(ord(t)=1,
                 Pr(t,gamma,k) = pi_L(gamma)*pi_M(k);
         );
         IF(ord(t)=2,
                 Pr(t,gamma,k) = pi_M(k);
         );
);
Display Pr;


****** Other-regards parameters
Scalar           chi_SoS         'Security of supply coefficient'        /1.05/;
Parameter        DR(t)           'Discount rate at year t';
DR(t)=0.0;
Parameter        a(t)            'Amortization rate';
a(t)=0.1;

***** Parameters to be updated for each long-term scenarios
Parameters
b_D(t,d,b)
P_D_max(t,d,b)
C_E(t,e)
P_R_max(t,r)
C_R(t,r)
C_C(t,c)
C_inv(t,c)
m_PH_model(t,c)
m_PH_LB_model(t,c)
X_C_avr_model(t,c)
;
Scalar rho /1000/;

****** Decision variables
****** Investment decisions

Positive variables
         X_C(t,c)                'Installed capacity of candidate unit c to be built';
****** Strategic behaviour variables
Positive Variables
         PP_E_max(e,t,h)         'Offering quantity of an exisitng unit'
         PP_C_max(c,t,h)         'Offering quantity of a cadidate unit'
         Beta_E(e,t,h)           'Offering price of an exisitng unit'
         Beta_C(c,t,h)           'Offering price of a cadidate unit'
;
Positive variables
         P_D(t,h,d,b)            'Scheduled demand quantity'
         P_R(t,h,r)              'Scheduled rival unit generaton quantity'
         P_E(t,h,e)              'Scheduled existing unit generaton quantity'
         P_C(t,h,c)              'Scheduled candidate unit generaton quantity'

         mu_D_l(t,h,d,b)
         mu_D_u(t,h,d,b)
         mu_R_l(t,h,r)
         mu_R_u(t,h,r)
         mu_E_l(t,h,e)
         mu_E_u(t,h,e)
         mu_C_l(t,h,c)
         mu_C_u(t,h,c)

Free variables
         z                       'Social welfare value'
         lambda_DA(t,h)          'Day-ahead electricity price'
;
SOS1 variables
         nu_D_l(t,h,d,b,y)
         nu_D_u(t,h,d,b,y)
         nu_R_l(t,h,r,y)
         nu_R_u(t,h,r,y)
         nu_E_l(t,h,e,y)
         nu_E_u(t,h,e,y)
         nu_C_l(t,h,c,y)
         nu_C_u(t,h,c,y)

;
Equations
         OBJ
         OBJ_PH
         OBJ_LB

         INV_X_C(t,c)
         INV_BUDGET(t)
         SoS(t,h)

         MAX_P_E_Conv(e_g,t,h)
         MAX_P_E_WP(e_w,t,h)
         MAX_P_C_Conv(c_g,t,h)
         MAX_P_C_WP(c_w,t,h)

         DA_PB(t,h)

         D_DA_MAX(t,h,d,b)
         R_DA_MAX_conv(t,h,r_g)
         R_DA_MAX_wp(t,h,r_w)
         E_DA_MAX(t,h,e)
         C_DA_MAX(t,h,c)

         STAT1(t,h,d,b)
         STAT2(t,h,r)
         STAT3(t,h,e)
         STAT4(t,h,c)

         SOS1_D_l(t,h,d,b)
         SOS2_D_l(t,h,d,b)
         SOS1_D_u(t,h,d,b)
         SOS2_D_u(t,h,d,b)
         SOS1_R_l(t,h,r)
         SOS2_R_l(t,h,r)
         SOS1_R_u_conv(t,h,r_g)
         SOS2_R_u_conv(t,h,r_g)
         SOS1_R_u_wp(t,h,r_w)
         SOS2_R_u_wp(t,h,r_w)
         SOS1_E_l(t,h,e)
         SOS2_E_l(t,h,e)
         SOS1_E_u(t,h,e)
         SOS2_E_u(t,h,e)
         SOS1_C_l(t,h,c)
         SOS2_C_l(t,h,c)
         SOS1_C_u(t,h,c)
         SOS2_C_u(t,h,c)
;
OBJ..
         sum(t,  1/(1+DR(t))**(ord(t))*(sum(h, N_MC(h)*(
                 - sum(e, C_E(t,e)*P_E(t,h,e))
                 - sum(c, C_C(t,c)*P_C(t,h,c))
                 + sum((d,b), b_D(t,d,b)*P_D(t,h,d,b))
                 - sum(r, C_R(t,r)*P_R(t,h,r))
                 - sum((d,b), mu_D_u(t,h,d,b)*P_D_max(t,d,b)*K_DF(h))
                 - sum(r_w, mu_R_u(t,h,r_w)*P_R_max(t,r_w)*K_CF_R(h,r_w))
                 - sum(r_g, mu_R_u(t,h,r_g)*P_R_max(t,r_g))))
                 -a(t)*sum(c, C_inv(t,c)*sum(tau$(ord(tau)<=ord(t)), X_C(tau,c))))) =E= z;

OBJ_PH..
         sum(t,  1/(1+DR(t))**(ord(t))*(sum(h, N_MC(h)*(
                 - sum(e, C_E(t,e)*P_E(t,h,e))
                 - sum(c, C_C(t,c)*P_C(t,h,c))
                 + sum((d,b), b_D(t,d,b)*P_D(t,h,d,b))
                 - sum(r, C_R(t,r)*P_R(t,h,r))
                 - sum((d,b), mu_D_u(t,h,d,b)*P_D_max(t,d,b)*K_DF(h))
                 - sum(r_w, mu_R_u(t,h,r_w)*P_R_max(t,r_w)*K_CF_R(h,r_w))
                 - sum(r_g, mu_R_u(t,h,r_g)*P_R_max(t,r_g))))
                 -a(t)*sum(c, C_inv(t,c)*sum(tau$(ord(tau)<=ord(t)), X_C(tau,c)))))
         - sum((t,c), m_PH_model(t,c)*X_C(t,c))
         - sum((t,c), rho/2*(X_C(t,c)-X_C_avr_model(t,c))*(X_C(t,c)-X_C_avr_model(t,c))) =E= z;

OBJ_LB..
         sum(t,  1/(1+DR(t))**(ord(t))*(sum(h, N_MC(h)*(
                 - sum(e, C_E(t,e)*P_E(t,h,e))
                 - sum(c, C_C(t,c)*P_C(t,h,c))
                 + sum((d,b), b_D(t,d,b)*P_D(t,h,d,b))
                 - sum(r, C_R(t,r)*P_R(t,h,r))
                 - sum((d,b), mu_D_u(t,h,d,b)*P_D_max(t,d,b)*K_DF(h))
                 - sum(r_w, mu_R_u(t,h,r_w)*P_R_max(t,r_w)*K_CF_R(h,r_w))
                 - sum(r_g, mu_R_u(t,h,r_g)*P_R_max(t,r_g))))
                 -a(t)*sum(c, C_inv(t,c)*sum(tau$(ord(tau)<=ord(t)), X_C(tau,c)))))
         - sum((t,c), m_PH_LB_model(t,c)*X_C(t,c)) =E= z;

INV_X_C(t,c)..
         X_C(t,c) =L= X_C_max(c);

INV_BUDGET(t)..
         sum(c, X_C(t,c)*C_inv(t,c)) =L= I_max(t);

SoS(t,h)..
         sum(e, PP_E_max(e,t,h)) + sum(c, PP_C_max(c,t,h)) + sum(r, P_R_max(t,r)) =G= sum((d,b), P_D_max(t,d,b))*K_DF(h)*chi_SoS;

MAX_P_E_Conv(e_g,t,h)..
         PP_E_max(e_g,t,h) =L= X_E_max(e_g);

MAX_P_E_WP(e_w,t,h)..
         PP_E_max(e_w,t,h) =L= X_E_max(e_w)*K_CF_E(h,e_w);

MAX_P_C_Conv(c_g,t,h)..
         PP_C_max(c_g,t,h) =L= sum(tau$(ord(tau)<=ord(t)), X_C(tau,c_g));

MAX_P_C_WP(c_w,t,h)..
         PP_C_max(c_w,t,h) =L= sum(tau$(ord(tau)<=ord(t)), X_C(tau,c_w))*K_CF_C(h,c_w);

DA_PB(t,h)..
         sum(r, P_R(t,h,r)) + sum(e, P_E(t,h,e)) + sum(c, P_C(t,h,c)) - sum((d,b), P_D(t,h,d,b)) =E= 0;

D_DA_MAX(t,h,d,b)..
         P_D(t,h,d,b) =L= P_D_max(t,d,b)*K_DF(h);

R_DA_MAX_conv(t,h,r_g)..
         P_R(t,h,r_g) =L= P_R_max(t,r_g);

R_DA_MAX_wp(t,h,r_w)..
         P_R(t,h,r_w) =L= P_R_max(t,r_w)*K_CF_R(h,r_w);

E_DA_MAX(t,h,e)..
         P_E(t,h,e) =L= PP_E_max(e,t,h);

C_DA_MAX(t,h,c)..
         P_C(t,h,c) =L= PP_C_max(c,t,h);

STAT1(t,h,d,b)..
         -b_D(t,d,b) + lambda_DA(t,h) + mu_D_u(t,h,d,b) - mu_D_l(t,h,d,b) =E= 0;

STAT2(t,h,r)..
         C_R(t,r) - lambda_DA(t,h) + mu_R_u(t,h,r) - mu_R_l(t,h,r) =E= 0;

STAT3(t,h,e)..
         Beta_E(e,t,h) - lambda_DA(t,h) + mu_E_u(t,h,e) - mu_E_l(t,h,e) =E= 0;

STAT4(t,h,c)..
         Beta_C(c,t,h) - lambda_DA(t,h) + mu_C_u(t,h,c) - mu_C_l(t,h,c)  =E= 0;

SOS1_D_l(t,h,d,b)..
         nu_D_l(t,h,d,b,'y1') + nu_D_l(t,h,d,b,'y2') =E= mu_D_l(t,h,d,b) + P_D(t,h,d,b);

SOS2_D_l(t,h,d,b)..
         nu_D_l(t,h,d,b,'y1') - nu_D_l(t,h,d,b,'y2') =E= mu_D_l(t,h,d,b) - P_D(t,h,d,b);

SOS1_D_u(t,h,d,b)..
         nu_D_u(t,h,d,b,'y1') + nu_D_u(t,h,d,b,'y2') =E= mu_D_u(t,h,d,b) + [P_D_max(t,d,b)*K_DF(h) - P_D(t,h,d,b)];

SOS2_D_u(t,h,d,b)..
         nu_D_u(t,h,d,b,'y1') - nu_D_u(t,h,d,b,'y2') =E= mu_D_u(t,h,d,b) - [P_D_max(t,d,b)*K_DF(h) - P_D(t,h,d,b)];

SOS1_R_l(t,h,r)..
         nu_R_l(t,h,r,'y1') + nu_R_l(t,h,r,'y2') =E= mu_R_l(t,h,r) + P_R(t,h,r);

SOS2_R_l(t,h,r)..
         nu_R_l(t,h,r,'y1') - nu_R_l(t,h,r,'y2') =E= mu_R_l(t,h,r) - P_R(t,h,r);

SOS1_R_u_conv(t,h,r_g)..
         nu_R_u(t,h,r_g,'y1') + nu_R_u(t,h,r_g,'y2') =E= mu_R_u(t,h,r_g) + [P_R_max(t,r_g) - P_R(t,h,r_g)];

SOS2_R_u_conv(t,h,r_g)..
         nu_R_u(t,h,r_g,'y1') - nu_R_u(t,h,r_g,'y2') =E= mu_R_u(t,h,r_g) - [P_R_max(t,r_g) - P_R(t,h,r_g)];

SOS1_R_u_wp(t,h,r_w)..
         nu_R_u(t,h,r_w,'y1') + nu_R_u(t,h,r_w,'y2') =E= mu_R_u(t,h,r_w) + [P_R_max(t,r_w)*K_CF_R(h,r_w) - P_R(t,h,r_w)];

SOS2_R_u_wp(t,h,r_w)..
         nu_R_u(t,h,r_w,'y1') - nu_R_u(t,h,r_w,'y2') =E= mu_R_u(t,h,r_w) - [P_R_max(t,r_w)*K_CF_R(h,r_w) - P_R(t,h,r_w)];

SOS1_E_l(t,h,e)..
         nu_E_l(t,h,e,'y1') + nu_E_l(t,h,e,'y2') =E= mu_E_l(t,h,e) + P_E(t,h,e);

SOS2_E_l(t,h,e)..
         nu_E_l(t,h,e,'y1') - nu_E_l(t,h,e,'y2') =E= mu_E_l(t,h,e) - P_E(t,h,e);

SOS1_E_u(t,h,e)..
         nu_E_u(t,h,e,'y1') + nu_E_u(t,h,e,'y2') =E= mu_E_u(t,h,e) + [PP_E_max(e,t,h) - P_E(t,h,e)];

SOS2_E_u(t,h,e)..
         nu_E_u(t,h,e,'y1') - nu_E_u(t,h,e,'y2') =E= mu_E_u(t,h,e) - [PP_E_max(e,t,h) - P_E(t,h,e)];

SOS1_C_l(t,h,c)..
         nu_C_l(t,h,c,'y1') + nu_C_l(t,h,c,'y2') =E= mu_C_l(t,h,c) + P_C(t,h,c);

SOS2_C_l(t,h,c)..
         nu_C_l(t,h,c,'y1') - nu_C_l(t,h,c,'y2') =E= mu_C_l(t,h,c) - P_C(t,h,c);

SOS1_C_u(t,h,c)..
         nu_C_u(t,h,c,'y1') + nu_C_u(t,h,c,'y2') =E= mu_C_u(t,h,c) + [PP_C_max(c,t,h) - P_C(t,h,c)];

SOS2_C_u(t,h,c)..
         nu_C_u(t,h,c,'y1') - nu_C_u(t,h,c,'y2') =E= mu_C_u(t,h,c) - [PP_C_max(c,t,h) - P_C(t,h,c)];

Model Scenario_specific /
OBJ
INV_X_C
INV_BUDGET
SoS
MAX_P_E_Conv
MAX_P_E_WP
MAX_P_C_Conv
MAX_P_C_WP
DA_PB
D_DA_MAX
R_DA_MAX_conv
R_DA_MAX_wp
E_DA_MAX
C_DA_MAX
STAT1
STAT2
STAT3
STAT4
SOS1_D_l
SOS2_D_l
SOS1_D_u
SOS2_D_u
SOS1_R_l
SOS2_R_l
SOS1_R_u_conv
SOS2_R_u_conv
SOS1_R_u_wp
SOS2_R_u_wp
SOS1_E_l
SOS2_E_l
SOS1_E_u
SOS2_E_u
SOS1_C_l
SOS2_C_l
SOS1_C_u
SOS2_C_u
/;
Model Scenario_specific_PH /
OBJ_PH
INV_X_C
INV_BUDGET
SoS
MAX_P_E_Conv
MAX_P_E_WP
MAX_P_C_Conv
MAX_P_C_WP
DA_PB
D_DA_MAX
R_DA_MAX_conv
R_DA_MAX_wp
E_DA_MAX
C_DA_MAX
STAT1
STAT2
STAT3
STAT4
SOS1_D_l
SOS2_D_l
SOS1_D_u
SOS2_D_u
SOS1_R_l
SOS2_R_l
SOS1_R_u_conv
SOS2_R_u_conv
SOS1_R_u_wp
SOS2_R_u_wp
SOS1_E_l
SOS2_E_l
SOS1_E_u
SOS2_E_u
SOS1_C_l
SOS2_C_l
SOS1_C_u
SOS2_C_u
/;
Model Scenario_specific_PH_LB /
OBJ_LB
INV_X_C
INV_BUDGET
SoS
MAX_P_E_Conv
MAX_P_E_WP
MAX_P_C_Conv
MAX_P_C_WP
DA_PB
D_DA_MAX
R_DA_MAX_conv
R_DA_MAX_wp
E_DA_MAX
C_DA_MAX
STAT1
STAT2
STAT3
STAT4
SOS1_D_l
SOS2_D_l
SOS1_D_u
SOS2_D_u
SOS1_R_l
SOS2_R_l
SOS1_R_u_conv
SOS2_R_u_conv
SOS1_R_u_wp
SOS2_R_u_wp
SOS1_E_l
SOS2_E_l
SOS1_E_u
SOS2_E_u
SOS1_C_l
SOS2_C_l
SOS1_C_u
SOS2_C_u
/;

$onecho > cplex.opt
threads 3
$offecho
Scenario_specific.optfile=1;

$onecho > cplex.opt
threads 3
$offecho
Scenario_specific_PH.optfile=1;

$onecho > cplex.opt
threads 3
$offecho
Scenario_specific_PH_LB.optfile=1;


Parameter Save_X_C(PH_iter,t,gamma,k,c);
Parameter Save_X_C_avr(PH_iter,t,gamma,k,c);
Parameter m_PH(PH_iter,t,gamma,k,c);
Parameter Penalty(PH_iter,t,gamma,k,c);
Parameter D_LB(PH_iter,gamma,k);
Parameter Lower_bound(PH_iter);
Parameter D_UB(PH_iter,gamma,k);
Parameter Upper_bound(PH_iter);
Parameter g(PH_iter,t,gamma,k,c);
Parameter Converge;
Converge=0;
Parameter Conv(PH_iter,t,gamma,k,c);




* Extract data to check the quality of the solution at each iteration

Parameter COMP1(PH_iter,t,gamma,h,k,d,b);
Parameter COMP2(PH_iter,t,gamma,h,k,d,b);
Parameter COMP3(PH_iter,t,gamma,h,k,r);
Parameter COMP4(PH_iter,t,gamma,h,k,r_g);
Parameter COMP5(PH_iter,t,gamma,h,k,r_w);
Parameter COMP6(PH_iter,t,gamma,h,k,e);
Parameter COMP7(PH_iter,t,gamma,h,k,e);
Parameter COMP8(PH_iter,t,gamma,h,k,c);
Parameter COMP9(PH_iter,t,gamma,h,k,c);
Parameter Save_Lambda_DA(PH_iter,t,gamma,k,c,h);
Parameter Profit_non_lin(PH_iter,gamma,k);

Scalar epsilon /0.5/;


Loop(PH_iter$(not Converge),
IF(ord(PH_iter)=1,
         Loop((k,gamma),
                 b_D(t,d,b)=b_D_data(t,k,d,b);
                 P_D_max(t,d,b)=P_D_max_data(t,gamma,d,b);
                 C_E(t,e)=C_E_data(t,gamma,e);
                 P_R_max(t,r)=P_R_max_data(t,gamma,r);
                 C_R(t,r)=C_R_data(t,gamma,k,r);
                 C_C(t,c)=C_C_data(t,gamma,c);
                 C_inv(t,c)=C_inv_data(t,gamma,c);

                 Solve Scenario_specific maximizing z using mip;
                 Save_X_C(PH_iter,t,gamma,k,c) = X_C.l(t,c);
                 D_UB(PH_iter,gamma,k) = z.l;
                 COMP1(PH_iter,t,gamma,h,k,d,b) = mu_D_l.l(t,h,d,b) * P_D.l(t,h,d,b);
                 COMP2(PH_iter,t,gamma,h,k,d,b) = mu_D_u.l(t,h,d,b) * [P_D_max(t,d,b)*K_DF(h) - P_D.l(t,h,d,b)];
                 COMP3(PH_iter,t,gamma,h,k,r) = mu_R_l.l(t,h,r) * P_R.l(t,h,r);
                 COMP4(PH_iter,t,gamma,h,k,r_g) = mu_R_u.l(t,h,r_g) * [P_R_max(t,r_g) - P_R.l(t,h,r_g)];
                 COMP5(PH_iter,t,gamma,h,k,r_w) = mu_R_u.l(t,h,r_w) * [P_R_max(t,r_w)*K_CF_R(h,r_w) - P_R.l(t,h,r_w)];
                 COMP6(PH_iter,t,gamma,h,k,e) = mu_E_l.l(t,h,e) * P_E.l(t,h,e);
                 COMP7(PH_iter,t,gamma,h,k,e) = mu_E_u.l(t,h,e) * [PP_E_max.l(e,t,h) - P_E.l(t,h,e)];
                 COMP8(PH_iter,t,gamma,h,k,c) = mu_C_l.l(t,h,c) * P_C.l(t,h,c);
                 COMP9(PH_iter,t,gamma,h,k,c) = mu_C_u.l(t,h,c) * [PP_C_max.l(c,t,h) - P_C.l(t,h,c)];
         );
*        Compute average of investment decisions
         Loop((t,gamma,k,c),
                  Save_X_C_avr(PH_iter,t,gamma,k,c)= sum((gamma_pr,k_pr)$AM(t,gamma,k,gamma_pr,k_pr), Pr(t,gamma_pr,k_pr)*Save_X_C(PH_iter,t,gamma_pr,k_pr,c))/sum((gamma_pr,k_pr)$AM(t,gamma,k,gamma_pr,k_pr), Pr(t,gamma_pr,k_pr));
         );
*        Compute PH multiplier
         Loop((t,gamma,k,c),
                 m_PH(PH_iter,t,gamma,k,c) =  rho*(Save_X_C(PH_iter,t,gamma,k,c)-Save_X_C_avr(PH_iter,t,gamma,k,c));
         );
*        Compute upper bound
         Upper_bound(PH_iter)=sum((gamma,k), pi_L(gamma)*pi_M(k)*D_UB(PH_iter,gamma,k));
);
IF(ord(PH_iter)>1,
         Loop((k,gamma),
                 b_D(t,d,b)=b_D_data(t,k,d,b);
                 P_D_max(t,d,b)=P_D_max_data(t,gamma,d,b);
                 C_E(t,e)=C_E_data(t,gamma,e);
                 P_R_max(t,r)=P_R_max_data(t,gamma,r);
                 C_R(t,r)=C_R_data(t,gamma,k,r);
                 C_C(t,c)=C_C_data(t,gamma,c);
                 C_inv(t,c)=C_inv_data(t,gamma,c);
                 Loop((t,c),
                         m_PH_model(t,c)=m_PH(PH_iter-1,t,gamma,k,c);
                         X_C_avr_model(t,c)=Save_X_C_avr(PH_iter-1,t,gamma,k,c);
                 );
                 Solve Scenario_specific_PH maximizing z using MIQCP;
                 Save_X_C(PH_iter,t,gamma,k,c) = X_C.l(t,c);
                 Save_Lambda_DA(PH_iter,t,gamma,k,c,h) = lambda_DA.l(t,h);
         );
*        Compute average of investment decisions
         Loop((t,gamma,k,c),
                  Save_X_C_avr(PH_iter,t,gamma,k,c)= sum((gamma_pr,k_pr)$AM(t,gamma,k,gamma_pr,k_pr), Pr(t,gamma_pr,k_pr)*Save_X_C(PH_iter,t,gamma_pr,k_pr,c))/sum((gamma_pr,k_pr)$AM(t,gamma,k,gamma_pr,k_pr), Pr(t,gamma_pr,k_pr));
         );
*        Compute PH multiplier
         Loop((t,gamma,k,c),
                 m_PH(PH_iter,t,gamma,k,c) =  m_PH(PH_iter-1,t,gamma,k,c) + rho*(Save_X_C(PH_iter,t,gamma,k,c)-Save_X_C_avr(PH_iter,t,gamma,k,c));
         );
*        Compute lower bound
         Loop((gamma,k),
                  b_D(t,d,b)=b_D_data(t,k,d,b);
                  P_D_max(t,d,b)=P_D_max_data(t,gamma,d,b);
                  C_E(t,e)=C_E_data(t,gamma,e);
                  P_R_max(t,r)=P_R_max_data(t,gamma,r);
                  C_R(t,r)=C_R_data(t,gamma,k,r);
                  C_C(t,c)=C_C_data(t,gamma,c);
                  C_inv(t,c)=C_inv_data(t,gamma,c);

                  m_PH_LB_model(t,c) =  m_PH(PH_iter,t,gamma,k,c);
                  Solve Scenario_specific_PH_LB maximizing z using MIP;
                  D_LB(PH_iter,gamma,k) = z.l;
         );
         Lower_bound(PH_iter)=sum(gamma, pi_L(gamma)* sum(k, pi_M(k)*D_LB(PH_iter,gamma,k)));
*        Compute upper bound
         Loop((gamma,k),
                  b_D(t,d,b)=b_D_data(t,k,d,b);
                  P_D_max(t,d,b)=P_D_max_data(t,gamma,d,b);
                  C_E(t,e)=C_E_data(t,gamma,e);
                  P_R_max(t,r)=P_R_max_data(t,gamma,r);
                  C_R(t,r)=C_R_data(t,gamma,k,r);
                  C_C(t,c)=C_C_data(t,gamma,c);
                  C_inv(t,c)=C_inv_data(t,gamma,c);

                 Loop((t,c),
                         X_C.LO(t,c) = Save_X_C(PH_iter,t,gamma,k,c);
                         X_C.UP(t,c) = Save_X_C(PH_iter,t,gamma,k,c);
                 );
                 Solve Scenario_specific maximizing z using MIP;
                 D_UB(PH_iter,gamma,k) = z.l;
                 Loop((t,c),
                         X_C.LO(t,c) = 0;
                         X_C.UP(t,c) = 300000;
                 );
         );
         Upper_bound(PH_iter)=sum((gamma,k), pi_L(gamma)*pi_M(k)*D_UB(PH_iter,gamma,k));

*        Check convergence
         Loop((t,gamma,k,c),
                 g(PH_iter,t,gamma,k,c) = Save_X_C(PH_iter,t,gamma,k,c) - Save_X_C_avr(PH_iter,t,gamma,k,c);
                 Conv(PH_iter,t,gamma,k,c)=1$(abs(g(PH_iter,t,gamma,k,c))<=epsilon);
         );
         Converge=1$(sum((t,gamma,k,c), Conv(PH_iter,t,gamma,k,c))=card(t)*card(gamma)*card(k)*card(c));
);
);
Display Save_X_C, Save_X_C_avr, Lower_bound, Upper_bound;
*Display COMP1,COMP2,COMP3,COMP4,COMP5,COMP6,COMP7,COMP8,COMP9;

Scalar tcomp, texec, telapsed;
tcomp = TimeComp;
texec = TimeExec;
telapsed = TimeElapsed;
Display tcomp, texec, telapsed;

****************Export results
File results_PH_LT_MS_rho_10_3 /results_PH_LT_MS_rho_10_3.csv/;
results_PH_LT_MS_rho_10_3.pc=5;
Put results_PH_LT_MS_rho_10_3;
put "Investment decision per itteration"/;
Loop((t,gamma,k,c,PH_iter),
         put t.tl, gamma.tl, k.tl, c.tl, PH_iter.tl, Save_X_C(PH_iter,t,gamma,k,c)/
);
put "Lower bound of the objective function"/;
Loop(PH_iter,
         put PH_iter.tl, Lower_bound(PH_iter)/
);
put "Upper bound of the objective function"/;
Loop(PH_iter,
         put PH_iter.tl, Upper_bound(PH_iter)/
);
put "Time elapsed"/;
put  telapsed/;
putclose;
