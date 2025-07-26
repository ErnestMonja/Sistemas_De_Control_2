clear all; close all; 

% Datos dados por la tabla:
p1 = -3;
p2 = -2;
K = 10;
Sobrepaso = 15;
t_2percent = 3;
error = 0;
T = 0.07;

% Funciones de la Tarea 1
G = zpk([],[p1 p2],[K])
Tm = T
Gd = c2d(G, Tm, 'Z0H')


% Obtener los valores de Psita, wo y wd:
psita = (-log(Sobrepaso/100))/(sqrt(pi^2 + log(Sobrepaso/100)^2))   % psita = 0.5169
w_0 = 4/(psita*t_2percent)                                          % w_0 = 2.5793
w_d = w_0*sqrt(1 - psita^2)                                         % w_d = 2.2080
t_d = 2*pi/w_d                                                      % t_d = 2.8457

% Calcular la cantidad de muestras por ciclo de la frecuencia amortiguada w_d:
m = t_d/Tm                                                          % m = 40.6526

% Mediante la equivalencia de planos s y z determinar la ubicación de los polos
% deseados en el plano z:

% z = e^T*(-psita*w_0 +- j*w_d)  --> |z| = e^(psita*w_0*Tm) y fas_z = +-T*w_d
mod_z  = exp(-psita*w_0*Tm)                                          % mod_z = 0.9109
fas_z1 = +rad2deg(Tm*w_d)                                            % fas_z = +8.8555° (0.1546 rad)
fas_z2 = -rad2deg(Tm*w_d)                                            % fas_z = -8.8555° (0.1546 rad)

z_x = mod_z*cos(fas_z1)                                              % z_x = -0.7672
z_y = mod_z*sin(fas_z1)                                              % z_y = +-0.4910

% Seleccionar y diseñar al menos 2 controladores digitales en serie (PI,PD, PID o Adelanto) que cumplan 
% (para los polos dominantes) las especificaciones dadas mediante SISOTOOL , en caso de que no se cumplan 
% analizar el porque.
%  - La condición de error debe cumplirse con exactitud
%  - Construir el sistema de lazo cerrado y verificar los polos, ceros y respuesta temporal mediante el
%    codigo
sisotool(Gd)

C                                                                    % muestra el compensador importado de sisotool
F = feedback(C*Gd,1)                                                 % sistema de lazo cerrado
pole(F)
zero(F)
pzmap(F)
step(F)                                                              % respuesta al escalon


