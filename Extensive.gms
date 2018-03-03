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
option iterlim=999999999;           // avoid limit on iterations
option reslim=999999999;            // timelimit for solver in sec.
option optcr=0;                     // gap tolerance
option solprint=on;                 // include solution print in .lst file
option limrow=0;                    // limit number of rows in .lst file
option limcol=0;                    // limit number of columns in .lst file
option decimals=1;                  // defines decimals in output file
option mip=cplex;
//--------------------------------------------------------------------

Sets
t        'time periods'                                           /t1*t2/
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
;
Alias(t,tau);
Alias(gamma,gamma_pr)
Alias(k,k_pr)

***** Demand data
Parameter P_D_max(t,gamma,d,b)      'Actual power capacity of demand units';
P_D_max(t,gamma,d,b)=1050;
P_D_max('t2','gamma1',d,b)=P_D_max('t1','gamma1',d,b)*1.20;
P_D_max('t2','gamma2',d,b)=P_D_max('t1','gamma1',d,b)*1.00;
P_D_max('t2','gamma3',d,b)=P_D_max('t1','gamma1',d,b)*0.80;

Display P_D_max;

Parameter b_D(t,k,d,b)              'Utility of demand units';
b_D(t,k,d,'b1')=70;

***** Existing units of the strategic producer
Parameter X_E_max(e)                     'Power capacity of exisiting units';
X_E_max('e1')=100;
X_E_max('e2')=50;

Parameter C_E(t,gamma,e)            'Generating costs of existing units';
C_E(t,gamma,'e1')=35;
C_E(t,gamma,'e2')=0;

****** Rival units
Parameter P_R_max(t,gamma,r)        'Power capacity of rival units';
P_R_max(t,gamma,'r1')=50;
P_R_max(t,gamma,'r2')=800;
P_R_max(t,gamma,'r3')=100;
P_R_max(t,gamma,'r4')=100;
P_R_max(t,gamma,'r5')=300;

Parameter C_R(t,gamma,k,r)          'Generating costs of rival units';
C_R(t,gamma,k,'r1')=0;
C_R(t,gamma,k,'r2')=10;
C_R(t,gamma,k,'r3')=43;
C_R(t,gamma,k,'r4')=50;
C_R(t,gamma,k,'r5')=60;

C_R(t,gamma,'k2',r)=C_R(t,gamma,'k1',r)*1.1;
C_R(t,gamma,'k3',r)=C_R(t,gamma,'k1',r)*0.9;
Display C_R;

****** Investment data
Parameter X_C_max(c)                'Power capacity of candidate units';
X_C_max(c)=500;

Parameter C_C(t,gamma,c)            'Generating costs of candidate units';
C_C(t,gamma,'c1')=40;
C_C(t,gamma,'c2')=33;
C_C(t,gamma,'c3')=0;

Parameter C_inv(t,gamma,c)          'Investment costs of candidate units';
C_inv(t,gamma,'c1')=500000;
C_inv(t,gamma,'c2')=800000;
C_inv(t,gamma,'c3')=1000000;

Parameter I_max(t)                  'Investment budget';
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
Parameter AM(t,gamma,gamma_pr) 'non-anticipativity matrix';
AM(t,gamma,gamma_pr)=0;
Loop((t,gamma,gamma_pr),
         IF(ord(t)=1,
                 AM(t,gamma,gamma_pr) = 1;
         );
         IF(ord(t)=2,
                 IF(ord(gamma)=ord(gamma_pr),
                         AM(t,gamma,gamma_pr) = 1;
                 );

         );
);
Display AM;
****** Other-regards parameters
Scalar           chi_SoS         'Security of supply coefficient'        /1.05/;
Parameter        DR(t)           'Discount rate at year t';
DR(t)=0.0;
Parameter        a(t)            'Amortization rate';
a(t)=0.1;

****** Decision variables
****** Investment decisions
Positive variables
         X_C(t,gamma,c)                  'Installed capacity of candidate unit c to be built';
****** Strategic behaviour variables
Positive Variables
         PP_E_max(e,t,gamma,h,k)         'Offering quantity of an exisitng unit'
         PP_C_max(c,t,gamma,h,k)         'Offering quantity of a cadidate unit'
         Beta_E(e,t,gamma,h,k)           'Offering price of an exisitng unit'
         Beta_C(c,t,gamma,h,k)           'Offering price of a cadidate unit'
;
Positive variables
         P_D(t,gamma,h,k,d,b)            'Scheduled demand quantity'
         P_R(t,gamma,h,k,r)              'Scheduled rival unit generaton quantity'
         P_E(t,gamma,h,k,e)              'Scheduled existing unit generaton quantity'
         P_C(t,gamma,h,k,c)              'Scheduled candidate unit generaton quantity'

         mu_D_l(t,gamma,h,k,d,b)
         mu_D_u(t,gamma,h,k,d,b)
         mu_R_l(t,gamma,h,k,r)
         mu_R_u(t,gamma,h,k,r)
         mu_E_l(t,gamma,h,k,e)
         mu_E_u(t,gamma,h,k,e)
         mu_C_l(t,gamma,h,k,c)
         mu_C_u(t,gamma,h,k,c)

Free variables
         z                               'Social welfare value'
         lambda_DA(t,gamma,h,k)
;
SOS1 variables
         nu_D_l(t,gamma,h,k,d,b,y)
         nu_D_u(t,gamma,h,k,d,b,y)
         nu_R_l(t,gamma,h,k,r,y)
         nu_R_u(t,gamma,h,k,r,y)
         nu_E_l(t,gamma,h,k,e,y)
         nu_E_u(t,gamma,h,k,e,y)
         nu_C_l(t,gamma,h,k,c,y)
         nu_C_u(t,gamma,h,k,c,y)
;
Equations
         OBJ

         INV_X_C(t,gamma,c)
         INV_BUDGET(t,gamma)
         SoS(t,gamma,h,k)
         Anticip(t,gamma,gamma_pr,c)

         MAX_P_E_Conv(e_g,t,gamma,h,k)
         MAX_P_E_WP(e_w,t,gamma,h,k)
         MAX_P_C_Conv(c_g,t,gamma,h,k)
         MAX_P_C_WP(c_w,t,gamma,h,k)

         DA_PB(t,gamma,h,k)

         D_DA_MAX(t,gamma,h,k,d,b)
         R_DA_MAX_conv(t,gamma,h,k,r_g)
         R_DA_MAX_wp(t,gamma,h,k,r_w)
         E_DA_MAX(t,gamma,h,k,e)
         C_DA_MAX(t,gamma,h,k,c)

         STAT1(t,gamma,h,k,d,b)
         STAT2(t,gamma,h,k,r)
         STAT3(t,gamma,h,k,e)
         STAT4(t,gamma,h,k,c)

         SOS1_D_l(t,gamma,h,k,d,b)
         SOS2_D_l(t,gamma,h,k,d,b)
         SOS1_D_u(t,gamma,h,k,d,b)
         SOS2_D_u(t,gamma,h,k,d,b)
         SOS1_R_l(t,gamma,h,k,r)
         SOS2_R_l(t,gamma,h,k,r)
         SOS1_R_u_conv(t,gamma,h,k,r_g)
         SOS2_R_u_conv(t,gamma,h,k,r_g)
         SOS1_R_u_wp(t,gamma,h,k,r_w)
         SOS2_R_u_wp(t,gamma,h,k,r_w)
         SOS1_E_l(t,gamma,h,k,e)
         SOS2_E_l(t,gamma,h,k,e)
         SOS1_E_u(t,gamma,h,k,e)
         SOS2_E_u(t,gamma,h,k,e)
         SOS1_C_l(t,gamma,h,k,c)
         SOS2_C_l(t,gamma,h,k,c)
         SOS1_C_u(t,gamma,h,k,c)
         SOS2_C_u(t,gamma,h,k,c)
;
OBJ..
         sum(t,  1/(1+DR(t))**(ord(t))*sum(gamma, pi_L(gamma)*(sum(h, N_MC(h)*(sum(k, pi_M(k)*(
                 - sum(e, C_E(t,gamma,e)*P_E(t,gamma,h,k,e))
                 - sum(c, C_C(t,gamma,c)*P_C(t,gamma,h,k,c))
                 + sum((d,b), b_D(t,k,d,b)*P_D(t,gamma,h,k,d,b))
                 - sum(r, C_R(t,gamma,k,r)*P_R(t,gamma,h,k,r))
                 - sum((d,b), mu_D_u(t,gamma,h,k,d,b)*P_D_max(t,gamma,d,b)*K_DF(h))
                 - sum(r_w, mu_R_u(t,gamma,h,k,r_w)*P_R_max(t,gamma,r_w)*K_CF_R(h,r_w))
                 - sum(r_g, mu_R_u(t,gamma,h,k,r_g)*P_R_max(t,gamma,r_g))))))
                 -a(t)*sum(c, C_inv(t,gamma,c)*sum(tau$(ord(tau)<=ord(t)), X_C(tau,gamma,c)))))) =E= z;

INV_X_C(t,gamma,c)..
         X_C(t,gamma,c) =L= X_C_max(c);

INV_BUDGET(t,gamma)..
         sum(c, X_C(t,gamma,c)*C_inv(t,gamma,c)) =L= I_max(t);

SoS(t,gamma,h,k)..
         sum(e, PP_E_max(e,t,gamma,h,k)) + sum(c, PP_C_max(c,t,gamma,h,k)) + sum(r, P_R_max(t,gamma,r)) =G= sum((d,b), P_D_max(t,gamma,d,b))*K_DF(h)*chi_SoS;

Anticip(t,gamma,gamma_pr,c)$AM(t,gamma,gamma_pr)..
         X_C(t,gamma,c) =E= X_C(t,gamma_pr,c);

MAX_P_E_Conv(e_g,t,gamma,h,k)..
         PP_E_max(e_g,t,gamma,h,k) =L= X_E_max(e_g);

MAX_P_E_WP(e_w,t,gamma,h,k)..
         PP_E_max(e_w,t,gamma,h,k) =L= X_E_max(e_w)*K_CF_E(h,e_w);

MAX_P_C_Conv(c_g,t,gamma,h,k)..
         PP_C_max(c_g,t,gamma,h,k) =L= sum(tau$(ord(tau)<=ord(t)), X_C(tau,gamma,c_g));

MAX_P_C_WP(c_w,t,gamma,h,k)..
         PP_C_max(c_w,t,gamma,h,k) =L= sum(tau$(ord(tau)<=ord(t)), X_C(tau,gamma,c_w))*K_CF_C(h,c_w);

DA_PB(t,gamma,h,k)..
         sum(r, P_R(t,gamma,h,k,r)) + sum(e, P_E(t,gamma,h,k,e)) + sum(c, P_C(t,gamma,h,k,c)) - sum((d,b), P_D(t,gamma,h,k,d,b)) =E= 0;

D_DA_MAX(t,gamma,h,k,d,b)..
         P_D(t,gamma,h,k,d,b) =L= P_D_max(t,gamma,d,b)*K_DF(h);

R_DA_MAX_conv(t,gamma,h,k,r_g)..
         P_R(t,gamma,h,k,r_g) =L= P_R_max(t,gamma,r_g);

R_DA_MAX_wp(t,gamma,h,k,r_w)..
         P_R(t,gamma,h,k,r_w) =L= P_R_max(t,gamma,r_w)*K_CF_R(h,r_w);

E_DA_MAX(t,gamma,h,k,e)..
         P_E(t,gamma,h,k,e) =L= PP_E_max(e,t,gamma,h,k);

C_DA_MAX(t,gamma,h,k,c)..
         P_C(t,gamma,h,k,c) =L= PP_C_max(c,t,gamma,h,k);

STAT1(t,gamma,h,k,d,b)..
         -b_D(t,k,d,b) + lambda_DA(t,gamma,h,k) + mu_D_u(t,gamma,h,k,d,b) - mu_D_l(t,gamma,h,k,d,b) =E= 0;

STAT2(t,gamma,h,k,r)..
         C_R(t,gamma,k,r) - lambda_DA(t,gamma,h,k) + mu_R_u(t,gamma,h,k,r) - mu_R_l(t,gamma,h,k,r) =E= 0;

STAT3(t,gamma,h,k,e)..
         Beta_E(e,t,gamma,h,k) - lambda_DA(t,gamma,h,k) + mu_E_u(t,gamma,h,k,e) - mu_E_l(t,gamma,h,k,e) =E= 0;

STAT4(t,gamma,h,k,c)..
         Beta_C(c,t,gamma,h,k) - lambda_DA(t,gamma,h,k) + mu_C_u(t,gamma,h,k,c) - mu_C_l(t,gamma,h,k,c)  =E= 0;

SOS1_D_l(t,gamma,h,k,d,b)..
         nu_D_l(t,gamma,h,k,d,b,'y1') + nu_D_l(t,gamma,h,k,d,b,'y2') =E= mu_D_l(t,gamma,h,k,d,b) + P_D(t,gamma,h,k,d,b);

SOS2_D_l(t,gamma,h,k,d,b)..
         nu_D_l(t,gamma,h,k,d,b,'y1') - nu_D_l(t,gamma,h,k,d,b,'y2') =E= mu_D_l(t,gamma,h,k,d,b) - P_D(t,gamma,h,k,d,b);

SOS1_D_u(t,gamma,h,k,d,b)..
         nu_D_u(t,gamma,h,k,d,b,'y1') + nu_D_u(t,gamma,h,k,d,b,'y2') =E= mu_D_u(t,gamma,h,k,d,b) + [P_D_max(t,gamma,d,b)*K_DF(h) - P_D(t,gamma,h,k,d,b)];

SOS2_D_u(t,gamma,h,k,d,b)..
         nu_D_u(t,gamma,h,k,d,b,'y1') - nu_D_u(t,gamma,h,k,d,b,'y2') =E= mu_D_u(t,gamma,h,k,d,b) - [P_D_max(t,gamma,d,b)*K_DF(h) - P_D(t,gamma,h,k,d,b)];

SOS1_R_l(t,gamma,h,k,r)..
         nu_R_l(t,gamma,h,k,r,'y1') + nu_R_l(t,gamma,h,k,r,'y2') =E= mu_R_l(t,gamma,h,k,r) + P_R(t,gamma,h,k,r);

SOS2_R_l(t,gamma,h,k,r)..
         nu_R_l(t,gamma,h,k,r,'y1') - nu_R_l(t,gamma,h,k,r,'y2') =E= mu_R_l(t,gamma,h,k,r) - P_R(t,gamma,h,k,r);

SOS1_R_u_conv(t,gamma,h,k,r_g)..
         nu_R_u(t,gamma,h,k,r_g,'y1') + nu_R_u(t,gamma,h,k,r_g,'y2') =E= mu_R_u(t,gamma,h,k,r_g) + [P_R_max(t,gamma,r_g) - P_R(t,gamma,h,k,r_g)];

SOS2_R_u_conv(t,gamma,h,k,r_g)..
         nu_R_u(t,gamma,h,k,r_g,'y1') - nu_R_u(t,gamma,h,k,r_g,'y2') =E= mu_R_u(t,gamma,h,k,r_g) - [P_R_max(t,gamma,r_g) - P_R(t,gamma,h,k,r_g)];

SOS1_R_u_wp(t,gamma,h,k,r_w)..
         nu_R_u(t,gamma,h,k,r_w,'y1') + nu_R_u(t,gamma,h,k,r_w,'y2') =E= mu_R_u(t,gamma,h,k,r_w) + [P_R_max(t,gamma,r_w)*K_CF_R(h,r_w) - P_R(t,gamma,h,k,r_w)];

SOS2_R_u_wp(t,gamma,h,k,r_w)..
         nu_R_u(t,gamma,h,k,r_w,'y1') - nu_R_u(t,gamma,h,k,r_w,'y2') =E= mu_R_u(t,gamma,h,k,r_w) - [P_R_max(t,gamma,r_w)*K_CF_R(h,r_w) - P_R(t,gamma,h,k,r_w)];

SOS1_E_l(t,gamma,h,k,e)..
         nu_E_l(t,gamma,h,k,e,'y1') + nu_E_l(t,gamma,h,k,e,'y2') =E= mu_E_l(t,gamma,h,k,e) + P_E(t,gamma,h,k,e);

SOS2_E_l(t,gamma,h,k,e)..
         nu_E_l(t,gamma,h,k,e,'y1') - nu_E_l(t,gamma,h,k,e,'y2') =E= mu_E_l(t,gamma,h,k,e) - P_E(t,gamma,h,k,e);

SOS1_E_u(t,gamma,h,k,e)..
         nu_E_u(t,gamma,h,k,e,'y1') + nu_E_u(t,gamma,h,k,e,'y2') =E= mu_E_u(t,gamma,h,k,e) + [PP_E_max(e,t,gamma,h,k) - P_E(t,gamma,h,k,e)];

SOS2_E_u(t,gamma,h,k,e)..
         nu_E_u(t,gamma,h,k,e,'y1') - nu_E_u(t,gamma,h,k,e,'y2') =E= mu_E_u(t,gamma,h,k,e) - [PP_E_max(e,t,gamma,h,k) - P_E(t,gamma,h,k,e)];

SOS1_C_l(t,gamma,h,k,c)..
         nu_C_l(t,gamma,h,k,c,'y1') + nu_C_l(t,gamma,h,k,c,'y2') =E= mu_C_l(t,gamma,h,k,c) + P_C(t,gamma,h,k,c);

SOS2_C_l(t,gamma,h,k,c)..
         nu_C_l(t,gamma,h,k,c,'y1') - nu_C_l(t,gamma,h,k,c,'y2') =E= mu_C_l(t,gamma,h,k,c) - P_C(t,gamma,h,k,c);

SOS1_C_u(t,gamma,h,k,c)..
         nu_C_u(t,gamma,h,k,c,'y1') + nu_C_u(t,gamma,h,k,c,'y2') =E= mu_C_u(t,gamma,h,k,c) + [PP_C_max(c,t,gamma,h,k) - P_C(t,gamma,h,k,c)];

SOS2_C_u(t,gamma,h,k,c)..
         nu_C_u(t,gamma,h,k,c,'y1') - nu_C_u(t,gamma,h,k,c,'y2') =E= mu_C_u(t,gamma,h,k,c) - [PP_C_max(c,t,gamma,h,k) - P_C(t,gamma,h,k,c)];

Model Direct /all/;
$onecho > cplex.opt
threads 3
$offecho
Direct.optfile=1;
Solve Direct maximizing z using mip;

Parameter Capital_costs(t,gamma);
Capital_costs(t,gamma) = sum((c), X_C.l(t,gamma,c)*C_inv(t,gamma,c));
Display Capital_costs;

Parameter COMP1(t,gamma,h,k,d,b);
COMP1(t,gamma,h,k,d,b) = mu_D_l.l(t,gamma,h,k,d,b) * P_D.l(t,gamma,h,k,d,b);

Parameter COMP2(t,gamma,h,k,d,b);
COMP2(t,gamma,h,k,d,b) = mu_D_u.l(t,gamma,h,k,d,b) * [P_D_max(t,gamma,d,b)*K_DF(h) - P_D.l(t,gamma,h,k,d,b)];

Parameter COMP3(t,gamma,h,k,r);
COMP3(t,gamma,h,k,r) = mu_R_l.l(t,gamma,h,k,r) * P_R.l(t,gamma,h,k,r);

Parameter COMP4(t,gamma,h,k,r_g);
COMP4(t,gamma,h,k,r_g) = mu_R_u.l(t,gamma,h,k,r_g) * [P_R_max(t,gamma,r_g) - P_R.l(t,gamma,h,k,r_g)];

Parameter COMP5(t,gamma,h,k,r_w);
COMP5(t,gamma,h,k,r_w) = mu_R_u.l(t,gamma,h,k,r_w) * [P_R_max(t,gamma,r_w)*K_CF_R(h,r_w) - P_R.l(t,gamma,h,k,r_w)];

Parameter COMP6(t,gamma,h,k,e);
COMP6(t,gamma,h,k,e) = mu_E_l.l(t,gamma,h,k,e) * P_E.l(t,gamma,h,k,e);

Parameter COMP7(t,gamma,h,k,e);
COMP7(t,gamma,h,k,e) = mu_E_u.l(t,gamma,h,k,e) * [PP_E_max.l(e,t,gamma,h,k) - P_E.l(t,gamma,h,k,e)];

Parameter COMP8(t,gamma,h,k,c);
COMP8(t,gamma,h,k,c) = mu_C_l.l(t,gamma,h,k,c) * P_C.l(t,gamma,h,k,c);

Parameter COMP9(t,gamma,h,k,c);
COMP9(t,gamma,h,k,c) = mu_C_u.l(t,gamma,h,k,c) * [PP_C_max.l(c,t,gamma,h,k) - P_C.l(t,gamma,h,k,c)];

Display COMP1,COMP2,COMP3,COMP4,COMP5,COMP6,COMP7,COMP8,COMP9;

Parameter Profit_non_lin;
Profit_non_lin =   sum(t,  1/(1+DR(t))**(ord(t)) *         sum(gamma, pi_L(gamma) *        (       sum(h, N_MC(h)* (       sum(k, pi_M(k) *      (
                 + sum(e, (lambda_DA.l(t,gamma,h,k)-C_E(t,gamma,e))*P_E.l(t,gamma,h,k,e))
                 + sum(c, (lambda_DA.l(t,gamma,h,k)-C_C(t,gamma,c))*P_C.l(t,gamma,h,k,c))
                                                                                                                                         )
                                                                                                                 )
                                                                                                         )
                                                                                         )
                 -a(t)*sum(c, C_inv(t,gamma,c)*sum(tau$(ord(tau)<=ord(t)), X_C.l(tau,gamma,c)))
                                                                                 )
                                                 )
         )
Display Profit_non_lin;

Scalar tcomp, texec, telapsed;
tcomp = TimeComp;
texec = TimeExec;
telapsed = TimeElapsed;
Display tcomp, texec, telapsed;
